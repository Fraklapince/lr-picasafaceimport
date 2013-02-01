local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import("LrFileUtils")
local LrDialogs = import("LrDialogs")
local LrView = import("LrView")
local LrStringUtils = import("LrStringUtils")
local prefs = import("LrPrefs").prefsForPlugin()
local LrBinding = import("LrBinding")
local bind = LrView.bind
local LrLogger = import("LrLogger")
local log = LrLogger("libraryLogger")
log:enable("logfile")

function observer(propertyTable, key, value)
  
  log:trace("Setting key " .. key .. " = " .. value)
  if key == "rootKeyword" then
    prefs.rootKeyword = value
  --[[
  elseif key == "contactsFrom" then
    if value == "nickname" then
      propertyTable.createSynonymText = LOC("$$$/Settings/SynonymName=Use Contact Name as Keyword Synonym")
      prefs.contactsFromNickname = true
    else
      propertyTable.createSynonymText = LOC("$$$/Settings/SynonymNickname=Use Contact Nickname as Keyword Synonym")
      prefs.contactsFromNickname = false
    end
  elseif key == "createSynonym" then
    if propertyTable.createSynonym == "1" then
      prefs.createSynonym = true
    else
      prefs.createSynonym = false
    end
  ]]
  elseif key == "UseSynonymForPicasaID" then
    if propertyTable.UseSynonymForPicasaID == "1" then
	  prefs.UseSynonymForPicasaID = true
	else
	  prefs.UseSynonymForPicasaID = false
	end
	LrDialogs.message("prefs.UseSynonymForPicasaID :".. tostring(prefs.UseSynonymForPicasaID))
	
  elseif key == "ImportBackgroudScanKey" then
    --if propertyTable.ImportBackgroudScanKey == "1" then	-- identique à if value == "1" then
	if value == "1" then
	  prefs.ImportBackgroudScan = true
	else
	  prefs.ImportBackgroudScan = false
	end

  elseif key == "contactsFile" then
    prefs.contactsFile = value
  end
end

return {
  sectionsForTopOfDialog = function(viewFactory, propertyTable)
    log:trace("Create view start")
    
	propertyTable.rootKeyword = prefs.rootKeyword
    --[[
	if prefs.contactsFromNickname == true then
      propertyTable.contactsFrom = "nickname"
      propertyTable.createSynonymText = LOC("$$$/Settings/SynonymName=Use Contact Name as Keyword Synonym")
    else
      propertyTable.contactsFrom = "name"
      propertyTable.createSynonymText = LOC("$$$/Settings/SynonymNickname=Use Contact Nickname as Keyword Synonym")
    end
    if prefs.createSynonym == true then
      propertyTable.createSynonym = "1"
    else
      propertyTable.createSynonym = "0"
    end
	]]
	
	if prefs.UseSynonymForPicasaID == true then
	  propertyTable.UseSynonymForPicasaID = "1"
	else
	  propertyTable.UseSynonymForPicasaID = "0"
	end
	LrDialogs.message("UseSynonymForPicasaID ".. propertyTable.UseSynonymForPicasaID .." / ".. tostring(prefs.UseSynonymForPicasaID))
	
	if prefs.ImportBackgroudScan == true then
	  propertyTable.ImportBackgroudScanKey = "1"
	else
	  propertyTable.ImportBackgroudScanKey = "0"
	end
	LrDialogs.message("ImportBackgroudScanKey ".. propertyTable.ImportBackgroudScanKey)
	
    propertyTable.contactsFile = prefs.contactsFile
	
    propertyTable:addObserver("rootKeyword", observer)
    --[[
	propertyTable:addObserver("contactsFrom", observer)
    propertyTable:addObserver("createSynonym", observer)
	]]
	propertyTable:addObserver("UseSynonymForPicasaID", observer)
	propertyTable:addObserver("contactsFile", observer)
	propertyTable:addObserver("ImportBackgroudScanKey", observer)
		
    if propertyTable.rootKeyword ~= nil then
      log:trace("Preference rootKeyword = " .. propertyTable.rootKeyword)
    end
	--[[
	if propertyTable.contactsFrom ~= nil then
      log:trace("Preference contactsFrom = " .. propertyTable.contactsFrom)
    end
    if propertyTable.createSynonym ~= nil then
      log:trace("Preference createSynonym = " .. propertyTable.createSynonym)
    end
	]]
    if propertyTable.UseSynonymForPicasaID ~= nil then
	  log:trace("Preference UseSynonymForPicasaID = " .. propertyTable.UseSynonymForPicasaID)
	end
	if propertyTable.contactsFile ~= nil then
      log:trace("Preference contactsFile = " .. propertyTable.contactsFile)
    end
	
    return {
      {
        title = LOC("$$$/Settings/Title=Settings"),
        bind_to_object = propertyTable,
        synopsis = LrView.bind({
          key = "rootKeyword",
          transform = function(value, from)
            return LOC("$$$/Settings/Synopsis=Root Keyword ^1", propertyTable.rootKeyword)
          end
        }),
        viewFactory:row({
          viewFactory:static_text({
            title = LOC("$$$/Settings/Instructions=To use PicasaFaceImport, select a photo and choose the menu item^r Library > Plug-in Extras > Import from Folder of Selected Photo^r^rPicasaFaceImport will:^r  1. Read the Contacts list from Picasa's Contacts.xml file,^r  2. Create a Keyword for each contact, under a Root Keyword defined below,^r  3. Read 'faces' metadata from .picasa.ini, located in the folder of the selected Photo,^r  5. Add contact Keywords to all Photos in the folder of the Selected Photo."),
            height_in_lines = 1.2
          })
        }),
        viewFactory:row({
          viewFactory:static_text({
            title = LOC("$$$/Settings/RootKeyword=Root Keyword Name ")
          }),
          viewFactory:edit_field({
            value = bind("rootKeyword"),
            fill_horizontal = 1,
            validate = function(view, value)
              log:trace("Validate Keyword " .. value)
              --propertyTable.contactsFromNickname = not contactsFromNickname
              value = LrStringUtils.trimWhitespace(value)
              if value == nil or value == "" then
                return false, propertyTable.rootKeyword, LOC("$$$/Error/RootKeywordEmpty=The Root Keyword Tag cannot be empty.")
              end
              if string.find(value, "[%c%*;,]+") ~= nil then
                return false, propertyTable.rootKeyword, LOC("$$$/Error/RootKeywordChars=The Keyword cannot contain a semicolon (;), comma (,), asterisk (*) or start or end with whitespace.")
              end
              return true, value
            end
          })
        }),
        --[[
		viewFactory:row({
          viewFactory:radio_button({
            title = LOC("$$$/Settings/RadioNickname=Use Contact Nickname as Keyword Name"),
            value = bind("contactsFrom"),
            checked_value = "nickname"
          }),
          viewFactory:spacer({
            width = viewFactory:control_spacing()
          }),
          viewFactory:radio_button({
            title = LOC("$$$/Settings/RadioName=Use Contact Name as Keyword Name"),
            value = bind("contactsFrom"),
            checked_value = "name"
          })
        }),
        viewFactory:row({
          viewFactory:spacer({
            width = viewFactory:control_spacing()
          }),
          viewFactory:checkbox({
            title = bind("createSynonymText"),
            value = bind("createSynonym"),
            checked_value = "1",
            unchecked_value = "0"
          })
        }),
		]]
		viewFactory:row({
		  viewFactory:checkbox({
		    title = LOC("$$$/Settings/RadioUseSynonymForPicasaID=Add Picasa contact ID as synonym for possible Lightroom name update"),
			value = bind("UseSynonymForPicasaID"),
			checked_value = "1",
			unchecked_value = "0"
		  })
		}),
		
		viewFactory:row({
		  viewFactory:checkbox({
		    title = LOC("$$$/Settings/RadioImportBackgroudScan=Detect Import and request for Face Import"),
			value = bind("ImportBackgroudScanKey"),
			checked_value = "1",
			unchecked_value = "0"
		  })
		}),
		
        viewFactory:row({
          viewFactory:static_text({
            title = LOC("$$$/Settings/ContactsFile=Picasa Contacts.xml")
          }),
          viewFactory:edit_field({
            value = bind("contactsFile"),
            fill_horizontal = 1,
            validate = function(view, value)
              if LrFileUtils.exists(value) ~= "file" then
                log:trace("File not found " .. LrFileUtils.exists(value))
                return false, propertyTable.contactsFile, LOC("$$$/Error/ContactsNotFoundTitle=Contacts.xml File Not Found!")
              end
              log:trace("File found " .. LrFileUtils.exists(value))
              return true, value
            end
          }),
          viewFactory:push_button({
            title = LOC("$$$/Settings/ContactsFileBrowse=^."),
            action = function(button)
              local f = LrDialogs.runOpenPanel({
                title = "Open Contacts.xml",
                canChooseFiles = true,
                canChooseDirectories = false,
                allowsMultipleSelection = false,
                fileTypes = "xml",
                initialDirectory = propertyTable.contactsFile
              })
              if #f == 1 then
                propertyTable.contactsFile = f[1]
                log:trace("Setting text propertyTable.contactsFile = " .. f[1])
              end
            end
          })
        }),
        viewFactory:row({
          viewFactory:push_button({
            title = LOC("$$$/Settings/Reset=Reset to default"),
            place_horizontal = 1,
            action = function(button)
              propertyTable.rootKeyword = LOC("$$$/Prefs/DefaultRootKeyword=Contacts")
              --[[
			  propertyTable.contactsFrom = "nickname"
              propertyTable.createSynonym = "1"
			  ]]
              propertyTable.contactsFile = nil
              local home = LrPathUtils.getStandardFilePath("home")
			  local find = {
				LOC("$$$/Prefs/ContactsFile1=Local Settings/Application Data/GooglePicasa2/contacts/contacts.xml"),
				LOC("$$$/Prefs/ContactsFile2=AppData/Local/Google/Picasa2/contacts/contacts.xml"),
				LOC("$$$/Prefs/ContactsFile3=Library/Application Support/Google/Picasa2/contacts/contacts.xml"),
				LOC("$$$/Prefs/ContactsFile4=Library/Application Support/Google/Picasa3/contacts/contacts.xml")
			  }
              for i = 1, #find do
                local file = LrPathUtils.child(home, find[i])
                if LrFileUtils.exists(file) == "file" then
                  propertyTable.contactsFile = file
                  break
                end
              end
            end
          })
        })
      }
    }
  end
}
