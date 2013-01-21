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

--local LrPlugin = import("LrPlugin")
dofile(_PLUGIN.path .. "/functions.lua")

log:enable("logfile")

local function PicasaFaceImport()
  progress = LrProgressScope({
    title = LOC("$$$/Progress/Title=PicasaFaceImport")
  })
  local folder = getCurrentFolder()	-- on ne passe que dans le folder courant ou le premier de l'arborescense
  LrDialogs.message("on ne parcours que:".. folder:getName() .." <br> on peut envisager de proposer de tout parcourir via un autre menu ou via une checkbox pour les sous dossiers")
  
  progress:setCaption(LOC("$$$/Progress/ReadingContacts=Reading Picasa Contacts"))
  local contacts, synonyms = readContacts(contactsFile)
  progress:setCaption(LOC("$$$/Progress/CreateKeywords=Creating Keyword for Contacts"))
  local keywords = createKeywords(contacts, synonyms)
  synonyms = nil
  progress:setCaption(LOC("$$$/Progress/AddKeywords=Adding Keywords to Photos"))
  cat:withWriteAccessDo(LOC("$$$/Undo/AddKeywords=Add Keywords to Photos"), function()
    readPicasaIni(folder, keywords)
  end)
  progress:done()
end

if contactsFile == nil or contactsFile == "" then
  do
    local LrDialogs = import("LrDialogs")
    LrDialogs.message(LOC("$$$/Error/ContactsNotFoundTitle=Contacts.xml File Not Found!"), LOC("$$$/Error/ContactsNotFoundText=PicasaFaceImport could not find Picasa's Contacts.xml.^r^rUse the Plug-in Manager to configure the location of this file."), "critical")
  end
else
  log:trace("Start PicasaFaceImport")
  local LrTasks = import("LrTasks")
  LrTasks.startAsyncTask(PicasaFaceImport)
end
