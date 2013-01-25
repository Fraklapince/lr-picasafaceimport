local LrPathUtils = import("LrPathUtils")
local LrStringUtils = import("LrStringUtils")
local LrApp = import("LrApplication")
local cat = LrApp.activeCatalog()
local prefs = import("LrPrefs").prefsForPlugin()
local contactsFile = prefs.contactsFile
local LrProgressScope = import("LrProgressScope")
local progress
local LrLogger = import("LrLogger")
local log = LrLogger("libraryLogger")
local LrDialogs = import("LrDialogs")

log:enable("logfile")

local function getPhotos(folder)
  local p = folder:getPhotos(false)
  local photos = {}
  for i = 1, #p do
    photos[LrStringUtils.upper(p[i]:getFormattedMetadata("fileName"))] = p[i]
  end
  return photos
end

local getKeywordNames = function(root)
  local n = root:getChildren()
  local names = {}
  for i = 1, #n do
    names[n[i]:getName()] = n[i]
  end
  return names
end

local function findKeywordName(root, childKeyword)
	-- PAS DE RECHERCHE RECURSIVE
	local n = root:getChildren()
	local childFounded = nil
	for i = 1, #n do
		if n[i]:getName() == childKeyword then
			--LrDialogs.message( "cherché ".. childKeyword .."trouvé: ".. n[i]:getName() )
			childFounded = n[i]
		end
	end
	return childFounded
end

local function findKeywordIdInSynonym(root, id)
	local childFounded = nil
	--LrDialogs.message( "cherché ".. id .. " dans ".. root:getName() .."/ " .. #root:getChildren() )
	local childSynonym = root:getSynonyms()
	for j = 1, #childSynonym do
		--LrDialogs.messageWithDoNotShow( {message="testé ".. childSynonym[j]  .. " avec " .. prefs.synonymIdLabelBase .. id, actionPrefKey="messageDoNotShow" })
		if childSynonym[j] == prefs.synonymIdLabelBase .. id then
			--LrDialogs.messageWithDoNotShow( {message="cherché ".. id .." trouvé: ".. childSynonym[j],  actionPrefKey="messageDoNotShow"} )
			childFounded = root
		end
	end
	
	local rootChild = root:getChildren()
	if #rootChild > 0 then
		for i = 1, #rootChild do
			findKeywordIdInSynonym(rootChild[i], id)
		end
	end
	
	return childFounded
end

function readContacts(contactXMLFile)
  local contacts = {}
  local synonyms = {}
  if contactXMLFile ~= nil then
    log:trace("Reading " .. contactXMLFile)
    local file = io.open(contactXMLFile)
    local LrXml = import("LrXml")
    local root = LrXml.parseXml(file:read("*a"))
    if root:name() == "contacts" then
      --local contactsFromNickname = prefs.contactsFromNickname
	  local useSynonymForPicasaID = prefs.UseSynonymForPicasaID
      
	  for i = 1, root:childCount() do
        local node = root:childAtIndex(i)
        if node:name() == "contact" then
          local attribs = node:attributes()
          local id = attribs.id.value
		  --[[  		  
          if contactsFromNickname == true then
            contacts[id] = attribs.display.value
            if attribs.display then
				synonyms[id] = attribs.name.value
			else
				synonyms[id] = ""
			end
          else
		  ]]
            contacts[id] = attribs.name.value
            --[[
			if attribs.display then
				synonyms[id] = attribs.display.value
			else
				synonyms[id] = ""
			end
			]]
		
			if useSynonymForPicasaID == true then
			  synonyms[id] = prefs.synonymIdLabelBase .. attribs.id.value	-- use ID as synonym for future update
			end
          --end
          log:trace("Contact " .. id .. " = " .. contacts[id] .. " (ID: " .. synonyms[id] .. ")")
        end
      end
    end
    file:close()
  end
  return contacts, synonyms
end

function readPicasaIni(folder, keywords)
  --LrDialogs.message("readPicasaIni: folder ".. folder:getName())
  
  local path = LrPathUtils.child(folder:getPath(), ".picasa.ini")
  local photos = getPhotos(folder)
  local p = 0
  local pp = #photos
  
  progress = LrProgressScope({
    title = LOC("$$$/Progress/TitleReadPicasaIni=PicasaFaceImport - readPicasaIni")
  })
  
  progress:setPortionComplete(p, pp)
  log:trace("Read " .. path)
  local file = io.open(path)
  if file ~= nil then
    local filename
    for line in file:lines() do
      if string.sub(line, 1, 1) == "[" then
        filename = LrStringUtils.upper(string.sub(line, 2, string.len(line) - 1))
        p = p + 1
        progress:setPortionComplete(p, pp)
      elseif string.sub(line, 1, 6) == "faces=" then
        local photo = photos[filename]
        if photo ~= nil then
          log:trace("Processing names for " .. filename)
          for location, id in string.gmatch(string.sub(line, 7), "rect64%((%w+)%),(%w+);*") do
            if id ~= "ffffffffffffffff" then
              local keyword = keywords[id]
              if keyword ~= nil then
                log:trace("Matched Keyword " .. keyword:getName())
                photo:addKeyword(keyword)
              end
            end
          end
        end
      end
    end
  file:close()
  end
  progress:setPortionComplete(pp, pp)
  progress:done()
  
  return "executed"
end

function createKeywords(contacts, synonyms)
  local root
  local rootKeyword = prefs.rootKeyword
  for k, v in pairs(cat:getKeywords()) do
    if v:getName() == rootKeyword then
      log:trace("Found Root Keyword " .. rootKeyword)
      root = v
      break
    end
  end
  if root == nil then
    cat:withWriteAccessDo(LOC("$$$/Undo/CreateRootKeyword=Create Root Keyword '^1'", rootKeyword), function()
      log:trace("Creating Root Keyword " .. rootKeyword)
      root = cat:createKeyword(rootKeyword, nil, true, nil)
    end)
  end

  local useSynonymForPicasaID = prefs.UseSynonymForPicasaID
  local keywords = {}
  local names = getKeywordNames(root)
  local count = 0
  
  for id, name in pairs(contacts) do
    count = count + 1
  end
  
  --[[
  for id, name in pairs(contacts) do
    local n = names[name]
	if n ~= nil then	
      keywords[id] = n		-- on recopie pour l'affectation future
      contacts[id] = nil	-- on détruit l'objet si on l'a trouvé
      count = count - 1
    else
		--LrDialogs.message( "non trouvé: ".. name)
		
		-- effectuer une recherche dans tous les enfants de "names" avant de dire qu'il faut créer le contact
		local child = nil
		for idChild, rootNames in pairs(names) do
			child = findKeywordName(rootNames, name)
			if child ~= nil then
				keywords[id] = child	-- on recopie pour l'affectation future
				contacts[id] = nil		-- on détruit l'objet si on l'a trouvé
				count = count - 1
				break
			end
		end
			
	end
  end
  ]]
  LrDialogs.resetDoNotShowFlag( messageDoNotShow )
  for id, name in pairs(contacts) do
	  if prefs.UseSynonymForPicasaID == true then
		
		for idName, rootNames in pairs(names) do
			--LrDialogs.messageWithDoNotShow( {message="UseSynonymForPicasaID ".. id .. " " .. name .. " - " .. rootNames:getName(), info="", actionPrefKey="messageDoNotShow" }  )
			
			child = findKeywordIdInSynonym(rootNames, id)
			if child ~= nil then
				keywords[id] = child	-- on recopie pour l'affectation future
				contacts[id] = nil		-- on détruit l'objet si on l'a trouvé
				count = count - 1
				break
			end
		end
	  else
		for idName, rootNames in pairs(names) do
			child = findKeywordName(rootNames, name)
			if child ~= nil then
				keywords[id] = child	-- on recopie pour l'affectation future
				contacts[id] = nil		-- on détruit l'objet si on l'a trouvé
				count = count - 1
				break
			end
		end
	  end
  end
  
  log:trace("Contacts to be created " .. count)
  if count > 0 then
    cat:withWriteAccessDo(LOC("$$$/Undo/CreateKeywords=Create Keywords for Contacts"), function()
      --local createSynonym = prefs.createSynonym
	  for id, name in pairs(contacts) do
        --[[
		if createSynonym == true then
          do
            local synonym = synonyms[id]
            if name == synonym then
              log:trace("Creating Keyword " .. name .. " with no Synonym")
              keywords[id] = cat:createKeyword(name, nil, true, root)
            else
              log:trace("Creating Keyword " .. name .. " with Synonym " .. synonym)
              keywords[id] = cat:createKeyword(name, {synonym}, true, root)
            end
          end
        else
		]]
		if useSynonymForPicasaID == true then
		  local synonymWithID = synonyms[id]
          log:trace("Creating Keyword without synonymID " .. name .. " / " .. synonymWithID)
          keywords[id] = cat:createKeyword(name, {synonymWithID}, true, root)
		else
		  log:trace("Creating Keyword without synonyms " .. name)
          keywords[id] = cat:createKeyword(name, nil, true, root)
		end
        --end
      end
    end)
  end
  return keywords
end

function locateFolder(folderName, folders)
  for i, folder in pairs(folders) do
    log:trace("Searching folder " .. folder:getName())
    if folder:getName() == folderName then
      log:trace("Folder found " .. folder:getPath())
      return folder
    end
    local subfolders = folder:getChildren()
    if subfolders ~= nil and #subfolders > 0 then
      local f = locateFolder(folderName, subfolders)
      if f ~= nil then
        return f
      end
    end
  end
end

function getCurrentFolder()
  local photo = LrApp.activeCatalog():getTargetPhoto()
  if photo ~= nil then
    return locateFolder(photo:getFormattedMetadata("folderName"), cat:getFolders())
  end
end

function readPicasaIniProcess(folder, keywords, subFolderTreatment)
	cat:withWriteAccessDo(LOC("$$$/Undo/AddKeywords=Add Keywords to Photos"), function()
		readPicasaIni(folder, keywords)
	end)
	
	if subFolderTreatment == true then
		local childrens = folder:getChildren()
		--LrDialogs.message( "nb of child: ".. #childrens)
		if #childrens > 0 then
			for i, child in pairs(childrens) do
				readPicasaIniProcess(child, keywords, subFolderTreatment)
			end
		end
	end
end


function PicasaFaceImport()
  
	local progress = LrProgressScope({
		title = LOC("$$$/Progress/Title=PicasaFaceImport")
	})

	progress:setCaption(LOC("$$$/Progress/ReadingContacts=Reading Picasa Contacts"))
	progress:setPortionComplete(1,3)
	local contacts, synonyms = readContacts(contactsFile)

	progress:setCaption(LOC("$$$/Progress/CreateKeywords=Creating Keyword for Contacts"))
	progress:setPortionComplete(2,3)
	local keywords = createKeywords(contacts, synonyms)

	synonyms = nil
	progress:setCaption(LOC("$$$/Progress/AddKeywords=Adding Keywords to Photos"))
	progress:setPortionComplete(3,3)
  
	if prefs.typeOfImport == "CurrentFolder" then
		-- si enabledWhen = "photosSelected" dans Info.lua, LrLibraryMenuItems argument
		local folder = getCurrentFolder()	-- on ne passe que dans le folder courant ou le premier de l'arborescense
		
		--LrDialogs.message( "Import from ".. folder:getName())
		
		--LrDialogs.message("Idee", "on ne parcours que:".. folder:getName() .." \r\n" .. "On peut envisager de proposer de tout parcourir via un autre menu ou via une checkbox pour les sous dossiers", "info")
		readPicasaIniProcess(folder, keywords, false)
		
	elseif prefs.typeOfImport == "SelectedFolder" then
		local folder = LrApp.activeCatalog():getActiveSources()
		local subFolderTreatment = false
		
		for i, folderElem in pairs( folder ) do
			if folderElem:type() == "LrFolder" then
				local childrens = folderElem:getChildren()
				if #childrens > 0 then
					local ret = LrDialogs.confirm(LOC("$$$/Message/SubFolderExistTitle=subfolder detection"), LOC("$$$/Message/SubFolderExist=One of the selected folder have subfolder(s) \r\ninclude them in the import faces process ?"), LOC("$$$/Message/Yes=Yes"), LOC("$$$/Message/No=No"))
					--LrDialogs.message( "Rte = ".. ret)
					if ret == "ok" then
						subFolderTreatment = true
					end
					break
				end
			end
		end
		
		
			
		for i, folderElem in pairs( folder ) do
			--LrDialogs.message( "folderElem:type() ".. folderElem:type())
			
			if folderElem:type() == "LrFolder" then
				--LrDialogs.message( "Import from ".. folderElem:getName() ..": ".. folderElem:getPath() .." - subfolderTreatment ".. tostring(subFolderTreatment))
				readPicasaIniProcess(folderElem, keywords, subFolderTreatment)
			end
		end
	end
	prefs.typeOfImport = nil
	
	progress:done()
  
	return "executed"
  
end
-----------------------------------------------------------------
-- General LUA functions

function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end