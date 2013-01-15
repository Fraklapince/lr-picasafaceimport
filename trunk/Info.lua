return {
  LrInitPlugin = "Init.lua",
  LrPluginInfoProvider = "Manager.lua",
  LrLibraryMenuItems = {
    {
      title = "$$$/Menu/Library=Import from Folder of Selected Photo",
      file = "Import.lua",
      enabledWhen = "photosSelected"
    }
  },
  LrHelpMenuItems = {
    {
      title = LOC("$$$/Menu/Help=PicasaFaceImport On-Line Help..."),
      file = "Help.lua"
    }
  },
  LrPluginName = "$$$/Menu/PluginNameDebug=PicasaFaceImport (Debug-FP)",
  LrSdkVersion = 3,
  LrSdkMinimumVersion = 1.3,
  LrToolkitIdentifier = "com.mybyways.PicasaFaceImport",
  LrPluginInfoUrl = "http://sites.google.com/site/mybyways/PicasaFaceImport",
  VERSION = {
    major = 1,
    minor = 0,
    revision = 0,
    display = "0.1.0 (Jan 2013)"
  }
}
