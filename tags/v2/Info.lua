return {
  LrInitPlugin = "Init.lua",
  LrPluginInfoProvider = "Manager.lua",
  LrLibraryMenuItems = {
    --[[{
      title = "$$$/Menu/SelectedPhotos=Import Faces for selected Photo(s)",
      file = "Import.lua"
	  , enabledWhen = "anythingSelected"
    },]]
	{
	  title = "$$$/Menu/SelectedFolder=Import Faces for selected Folder(s)",
      file = "ImportFolder.lua"
	}--[[,
	{
	  title = "$$$/Menu/Test=Test",
      file = "Test.lua"
	}]]
  },
  LrHelpMenuItems = {
    {
      title = LOC("$$$/Menu/Help=PicasaFaceImport On-Line Help..."),
      file = "Help.lua"
    }
  },
  LrPluginName = "$$$/Menu/PluginNameDebug=PicasaFaceImport",
  LrSdkVersion = 3,
  LrSdkMinimumVersion = 1.3,
  LrToolkitIdentifier = "com.google.code.mybyways.p.lr-picasafaceimport",
  LrPluginInfoUrl = "http://code.google.com/p/lr-picasafaceimport/",
  VERSION = {
    major = 1,
    minor = 0,
    revision = 0,
    display = "0.1.0 (Jan 2013)"
  },
  LrForceInitPlugin = true
}
