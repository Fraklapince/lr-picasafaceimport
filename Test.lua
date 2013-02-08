local LrApp = import("LrApplication")
local cat = LrApp.activeCatalog()
local LrDialogs = import("LrDialogs")

dofile(_PLUGIN.path .. "/functions.lua")

local LrTasks = import("LrTasks")

function BackgroundVerifyImport()
	while true then
		LrDialogs.message(cat.kPreviousImport)
		if true == cat:setActiveSources(cat.kPreviousImport) then
			LrDialogs.message("1")
		else
			LrDialogs.message("0")
		end

		local previousImportPhotos = cat:getMultipleSelectedOrAllPhotos()

		LrDialogs.message("Nb Of Photos ".. #previousImportPhotos)
		
		prefs.previousImportElementNb = #previousImportPhotos
		
		LrTasks.sleep(10)
	end
end

LrTasks.startAsyncTask(BackgroundVerifyImport) 