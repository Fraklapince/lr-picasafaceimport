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
  
  prefs.synonymIdLabelBase = LOC("$$$/Prefs/synonymIdLabelBase=picasaID:")
  
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