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
function observer(p, key, value)
  log:trace("Setting key " .. key .. " = " .. value)
  if key == "rootKeyword" then
    prefs.rootKeyword = value
  elseif key == "contactsFrom" then
    if value == "nickname" then
      p.createSynonymText = LOC("$$$/Settings/SynonymName=Use Contact Name as Keyword Synonym")
      prefs.contactsFromNickname = true
    else
      p.createSynonymText = LOC("$$$/Settings/SynonymNickname=Use Contact Nickname as Keyword Synonym")
      prefs.contactsFromNickname = false
    end
  elseif key == "createSynonym" then
    if p.createSynonym == "1" then
      prefs.createSynonym = true
    else
      prefs.createSynonym = false
    end
  elseif key == "contactsFile" then
    prefs.contactsFile = value
  end
end
return {
  sectionsForTopOfDialog = function(f, p)
    log:trace("Create view start")
    p.rootKeyword = prefs.rootKeyword
    if prefs.contactsFromNickname == true then
      p.contactsFrom = "nickname"
      p.createSynonymText = LOC("$$$/Settings/SynonymName=Use Contact Name as Keyword Synonym")
    else
      p.contactsFrom = "name"
      p.createSynonymText = LOC("$$$/Settings/SynonymNickname=Use Contact Nickname as Keyword Synonym")
    end
    if prefs.createSynonym == true then
      p.createSynonym = "1"
    else
      p.createSynonym = "0"
    end
    p.contactsFile = prefs.contactsFile
    p:addObserver("rootKeyword", observer)
    p:addObserver("contactsFrom", observer)
    p:addObserver("createSynonym", observer)
    p:addObserver("contactsFile", observer)
    if p.rootKeyword ~= nil then
      log:trace("Preference rootKeyword = " .. p.rootKeyword)
    end
    if p.contactsFrom ~= nil then
      log:trace("Preference contactsFrom = " .. p.contactsFrom)
    end
    if p.createSynonym ~= nil then
      log:trace("Preference createSynonym = " .. p.createSynonym)
    end
    if p.contactsFile ~= nil then
      log:trace("Preference contactsFile = " .. p.contactsFile)
    end
    return {
      {
        title = LOC("$$$/Settings/Title=Settings"),
        bind_to_object = p,
        synopsis = LrView.bind({
          key = "rootKeyword",
          transform = function(value, from)
            return LOC("$$$/Settings/Synopsis=Root Keyword ^1", p.rootKeyword)
          end
        }),
        f:row({
          f:static_text({
            title = LOC("$$$/Settings/Instructions=To use Faces2Keywords, select a photo and choose the menu item^r Library > Plug-in Extras > Import from Folder of Selected Photo^r^rFaces2Keywords will:^r  1. Read the Contacts list from Picasa's Contacts.xml file,^r  2. Create a Keyword for each contact, under a Root Keyword defined below,^r  3. Read 'faces' metadata from .picasa.ini, located in the folder of the selected Photo,^r  5. Add contact Keywords to all Photos in the folder of the Selected Photo."),
            height_in_lines = 1.2
          })
        }),
        f:row({
          f:static_text({
            title = LOC("$$$/Settings/RootKeyword=Root Keyword Name ")
          }),
          f:edit_field({
            value = bind("rootKeyword"),
            fill_horizontal = 1,
            validate = function(view, value)
              log:trace("Validate Keyword " .. value)
              p.contactsFromNickname = not contactsFromNickname
              value = LrStringUtils.trimWhitespace(value)
              if value == nil or value == "" then
                return false, p.rootKeyword, LOC("$$$/Error/RootKeywordEmpty=The Root Keyword Tag cannot be empty.")
              end
              if string.find(value, "[%c%*;,]+") ~= nil then
                return false, p.rootKeyword, LOC("$$$/Error/RootKeywordChars=The Keyword cannot contain a semicolon (;), comma (,), asterisk (*) or start or end with whitespace.")
              end
              return true, value
            end
          })
        }),
        f:row({
          f:radio_button({
            title = LOC("$$$/Settings/RadioNickname=Use Contact Nickname as Keyword Name"),
            value = bind("contactsFrom"),
            checked_value = "nickname"
          }),
          f:spacer({
            width = f:control_spacing()
          }),
          f:radio_button({
            title = LOC("$$$/Settings/RadioName=Use Contact Name as Keyword Name"),
            value = bind("contactsFrom"),
            checked_value = "name"
          })
        }),
        f:row({
          f:spacer({
            width = f:control_spacing()
          }),
          f:checkbox({
            title = bind("createSynonymText"),
            value = bind("createSynonym"),
            checked_value = "1",
            unchecked_value = "0"
          })
        }),
        f:row({
          f:static_text({
            title = LOC("$$$/Settings/ContactsFile=Picasa Contacts.xml")
          }),
          f:edit_field({
            value = bind("contactsFile"),
            fill_horizontal = 1,
            validate = function(view, value)
              if LrFileUtils.exists(value) ~= "file" then
                log:trace("File not found " .. LrFileUtils.exists(value))
                return false, p.contactsFile, LOC("$$$/Error/ContactsNotFoundTitle=Contacts.xml File Not Found!")
              end
              log:trace("File found " .. LrFileUtils.exists(value))
              return true, value
            end
          }),
          f:push_button({
            title = LOC("$$$/Settings/ContactsFileBrowse=^."),
            action = function(button)
              local f = LrDialogs.runOpenPanel({
                title = "Open Contacts.xml",
                canChooseFiles = true,
                canChooseDirectories = false,
                allowsMultipleSelection = false,
                fileTypes = "xml",
                initialDirectory = p.contactsFile
              })
              if #f == 1 then
                p.contactsFile = f[1]
                log:trace("Setting text p.contactsFile = " .. f[1])
              end
            end
          })
        }),
        f:row({
          f:push_button({
            title = LOC("$$$/Settings/Reset=Reset to default"),
            place_horizontal = 1,
            action = function(button)
              p.rootKeyword = LOC("$$$/Prefs/DefaultRootKeyword=Contacts")
              p.contactsFrom = "nickname"
              p.createSynonym = "1"
              p.contactsFile = nil
              local home = LrPathUtils.getStandardFilePath("home")
              local find = {
                LOC("$$$/Prefs/ContactsFile1=Local SettingsApplication DataGooglePicasa2contactscontacts.xml"),
                LOC("$$$/Prefs/ContactsFile2=AppDataLocalGooglePicasa2contactscontacts.xml"),
                LOC("$$$/Prefs/ContactsFile3=Library/Application Support/Google/Picasa2/contacts/contacts.xml"),
                LOC("$$$/Prefs/ContactsFile4=Library/Application Support/Google/Picasa3/contacts/contacts.xml")
              }
              for i = 1, #find do
                local f = LrPathUtils.child(home, find[i])
                if LrFileUtils.exists(f) == "file" then
                  p.contactsFile = f
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
