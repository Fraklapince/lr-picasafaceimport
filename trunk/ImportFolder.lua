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

local LrTasks = import("LrTasks")

--local LrPlugin = import("LrPlugin")
dofile(_PLUGIN.path .. "/functions.lua")

log:enable("logfile")

if contactsFile == nil or contactsFile == "" then
  do
    LrDialogs.message(LOC("$$$/Error/ContactsNotFoundTitle=Contacts.xml File Not Found!"), LOC("$$$/Error/ContactsNotFoundText=PicasaFaceImport could not find Picasa's Contacts.xml.^r^rUse the Plug-in Manager to configure the location of this file."), "critical")
  end
else
  log:trace("Start PicasaFaceImport - SelectedFolder")
  prefs.typeOfImport = "SelectedFolder"
  LrTasks.startAsyncTask(PicasaFaceImport)
end
