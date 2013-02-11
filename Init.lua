local LrFileUtils = import("LrFileUtils")
local LrPathUtils = import("LrPathUtils")
local LrDialogs = import("LrDialogs")

function init()
  local prefs = import("LrPrefs").prefsForPlugin()
  
  if prefs.rootKeyword == nil or prefs.rootKeyword == "" then
    prefs.rootKeyword = LOC("$$$/Prefs/DefaultRootKeyword=Contacts")
  end
  --[[
  if type(prefs.contactsFromNickname) ~= "boolean" then
    prefs.contactsFromNickname = true
  end
  if type(prefs.createSynonym) ~= "boolean" then
    prefs.createSynonym = true
  end
  ]]
  if type(prefs.UseSynonymForPicasaID) ~= "boolean" then
    prefs.UseSynonymForPicasaID = true
  end
  
  if type(prefs.ImportBackgroudScan) ~= "boolean" then
    prefs.ImportBackgroudScan = true
  end
  
  --LrDialogs.message("ImportBackgroudScan ".. tostring(prefs.ImportBackgroudScan))
  
  prefs.synonymIdLabelBase = LOC("$$$/Prefs/synonymIdLabelBase=picasaID:")
  
  --LrDialogs.message("ImportBackgroudScan ".. tostring(prefs.contactsFile))
  
  if prefs.contactsFile == nil or prefs.contactsFile == "" or LrFileUtils.exists(prefs.contactsFile) == false then
    prefs.contactsFile = nil
    local home = LrPathUtils.getStandardFilePath("home")
    local find = {
      LOC("$$$/Prefs/ContactsFile1=Local Settings/Application Data/GooglePicasa2/contacts/contacts.xml"),
      LOC("$$$/Prefs/ContactsFile2=AppData/Local/Google/Picasa2/contacts/contacts.xml"),
      LOC("$$$/Prefs/ContactsFile3=Library/Application Support/Google/Picasa2/contacts/contacts.xml"),
      LOC("$$$/Prefs/ContactsFile4=Library/Application Support/Google/Picasa3/contacts/contacts.xml")
    }
    for i = 1, #find do
      local f = LrPathUtils.child(home, find[i])
	  --LrDialogs.message("Try ".. f)
      if LrFileUtils.exists(f) == "file" then
        --LrDialogs.message("Found ".. f)
		prefs.contactsFile = f
        break
      end
    end
  end
  
  if prefs.contactsFile == nil or prefs.contactsFile == "" then
    local LrDialogs = import("LrDialogs")
    LrDialogs.message(LOC("$$$/Error/ContactsNotFoundTitle=Contacts.xml File Not Found!"), LOC("$$$/Error/ContactsNotFoundText=PicasaFaceImport could not find Picasa's Contacts.xml.^r^rUse the Plug-in Manager to configure the location of this file."), "critical")
  end
end

init()


local LrTasks = import("LrTasks")
local LrDialogs = import("LrDialogs")
local LrApp = import("LrApplication")
local cat = LrApp.activeCatalog()
local prefs = import("LrPrefs").prefsForPlugin()

function BackgroundVerifyImport()
	while true do
		--LrDialogs.message(cat.kPreviousImport)
		
		if true == cat:setActiveSources(cat.kPreviousImport) then
			--LrDialogs.message("1")
		else
			--LrDialogs.message("0")
		end

		local previousImportPhotos = 0
		
		-- http://feedback.photoshop.com/photoshop_family/topics/lightroom_sdk_add_function_to_get_a_list_of_photos_in_the_filmstrip
		
		if #cat:getTargetPhoto() >=	-- ==1 OR nill
			#cat:getMultipleSelectedOrAllPhotos() 	-- >1 OR All
		then
			previousImportPhotos = #cat:getTargetPhoto()
		else
			previousImportPhotos = #cat:getMultipleSelectedOrAllPhotos()
		end
		

		LrDialogs.message("Nb Of Photos 1 ".. previousImportPhotos .."/".. #cat:getTargetPhoto() .."-".. #cat:getMultipleSelectedOrAllPhotos())
		LrDialogs.message("photo ".. cat:getMultipleSelectedOrAllPhotos()[1].localIdentifier)
		cat:setSelectedPhotos(cat:getMultipleSelectedOrAllPhotos()[1], {})
		LrDialogs.message("Nb Of Photos 2 ".. previousImportPhotos .."/".. #cat:getTargetPhoto() .."-".. #cat:getMultipleSelectedOrAllPhotos())
		
		prefs.previousImportElementNb = previousImportPhotos
		
		LrTasks.sleep(10)
	end
end

LrDialogs.message("init")
if prefs.ImportBackgroudScan then
	LrDialogs.message("checked")
	LrTasks.startAsyncTask(BackgroundVerifyImport) 
end
