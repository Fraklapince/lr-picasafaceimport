mkdir PicasaFaceImport.lrplugin
luac -o ./PicasaFaceImport.lrplugin/functions.lua functions.lua
luac -o ./PicasaFaceImport.lrplugin/Help.lua Help.lua
luac -o PicasaFaceImport.lrplugin/Import.lua Import.lua
luac -o PicasaFaceImport.lrplugin/ImportFolder.lua ImportFolder.lua
luac -o PicasaFaceImport.lrplugin/Info.lua Info.lua
luac -o PicasaFaceImport.lrplugin/Init.lua Init.lua
luac -o PicasaFaceImport.lrplugin/Manager.lua Manager.lua
copy TranslatedStrings_en.txt PicasaFaceImport.lrplugin/TranslatedStrings_en.txt