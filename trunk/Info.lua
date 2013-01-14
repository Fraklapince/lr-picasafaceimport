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
      title = LOC("$$$/Menu/Help=Faces2Keywords On-Line Help..."),
      file = "Help.lua"
    }
  },
  LrPluginName = "$$$/Menu/PluginNameDebug=Faces2Keywords (Debug-FP)",
  LrSdkVersion = 3,
  LrSdkMinimumVersion = 1.3,
  LrToolkitIdentifier = "com.mybyways.faces2keywords",
  LrPluginInfoUrl = "http://sites.google.com/site/mybyways/faces2keywords",
  VERSION = {
    major = 1,
    minor = 0,
    revision = 0,
    display = "1.0.0 (10 Nov 2010)"
  }
}
