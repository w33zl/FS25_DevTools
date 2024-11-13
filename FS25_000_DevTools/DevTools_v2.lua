--[[

Author:     w33zl / WZL Modding
Version:    1.0.0
Modified:   2021-12-20

Facebook:           https://www.facebook.com/w33zl

Changelog:

]]

DevTools = Mod:init()

Log:info("I'm here")

Log:debug("I'm here 2")


DevTools:source("pixel_spy.lua")

local l_currentModSettingsDirectory = g_currentModSettingsDirectory

Commander = {
    test = function()
        Logging.info("test")
    end,
}

local function getOrInitGlobalMod(name)
    g_globalMods[name] = g_globalMods[name] or {}
    return g_globalMods[name]
end


-- Log:var("g_powerTools", g_powerTools)
-- Log:var("mod.__g.consoleCommandListCommands", DevTools.__g.consoleCommandListCommands)
-- Log:var("mod.__g.registeredConsoleCommands", DevTools.__g.registeredConsoleCommands)





-- setBrightness = function() end, -- function: 0x01f09a267ea8
-- getBrightnessNits = function() end, -- function: 0x01f09a267f10
-- setBrightnessNits = function() end, -- function: 0x01f09a267f80
-- updateLoadingBar = function() end, -- function: 0x01f09a267ff0
-- toggleShowFPS = function() end, -- function: 0x01f09a268060
-- toggleStatsOverlay = function() end, -- function: 0x01f09a2680c8
-- printStatsOverlay = function() end, -- function: 0x01f09a268138
-- setFileLogPrefixTimestamp = function() end, -- function: 0x01f09a2681a8
-- setFileLogName = function() end, -- function: 0x01f09a268220
-- printActiveEntities = function() end, -- function: 0x01f09a268288
-- executeConsoleCommand = function() end, -- function: 0x01f09a2682f8
-- setFramerateLimiter = function() end, -- function: 0x01f09a268368
-- getGamepadEnabled = function() end, -- function: 0x01f09a2683d8
-- setGamepadEnabled = function() end, -- function: 0x01f09a268448
-- getGamepadVibrationEnabled = function() end, -- function: 0x01f09a2684b8
-- setGamepadVibrationEnabled = function() end, -- function: 0x01f09a268530
-- getGamepadDefaultDeadzone = function() end, -- function: 0x01f09a2685a8
-- setGamepadDefaultDeadzone = function() end, -- function: 0x01f09a268620
-- beginInputFuzzing = function() end, -- function: 0x01f09a268698
-- getKeyName = function() end, -- function: 0x01f09a268708
-- getMouseButtonName = function() end, -- function: 0x01f09a268770
-- enableDevelopmentControls = function() end, -- function: 0x01f09a2687e0
-- getMasterVolume = function() end, -- function: 0x01f09a268858
-- setMasterVolume = function() end, -- function: 0x01f09a2688c0
-- getCurrentMasterVolume = function() end, -- function: 0x01f09a268928
-- setCurrentMasterVolume = function() end, -- function: 0x01f09a268998




_G.g_powerTools = getOrInitGlobalMod("FS22_PowerTools")

Log:table("g_powerTools", g_powerTools)

local function safeAddConsoleCommand(name, description, ...)
    g_powerTools.registeredConsoleCommands = g_powerTools.registeredConsoleCommands or {}

    if g_powerTools.registeredConsoleCommands[name] then
        Log:debug("Console command '%s' already registered, skipping.", name)
        return
    end

    local args = { ... }
    local success = pcall(function()
        addConsoleCommand(name, description, unpack(args))
    end)

    if success then
        g_powerTools.registeredConsoleCommands[name] = true
    else
        Log:warning("Failed to register console command '%s'", name)
    end
end


-- addConsoleCommand("tt", "Restart the game", "test", Commander)
-- addConsoleCommand("tt2", "Restart the game", "testCommand", g_powerTools)

-- safeAddConsoleCommand("tt", "Restart the game", "test", Commander)
-- safeAddConsoleCommand("tt2", "Restart the game", "testCommand", g_powerTools)
-- safeAddConsoleCommand("tt", "Restart the game", "test", Commander)

function DevTools:loadMap(filename)
    
    -- -- DebugUtil.printTableRecursively(_G, "_G:: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getfenv(0), "getfenv(0):: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getfenv(1), "getfenv(1):: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getfenv(2), "getfenv(2):: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getfenv(), "getfenv(nil):: ", 0, 1)

    -- local pt = _G["FS22_PowerTools"]
    -- local pt2 = getmetatable(_G).__index["FS22_PowerTools"]
    -- -- local pt3 = g_modManager.nameToMod["FS22_PowerTools"]

    -- Log:var("pt", pt)
    -- Log:var("pt2", pt2)
    -- -- Log:var("pt3", pt3)

    -- Log:table("pt table", pt)
    -- Log:table("pt2 table", pt2)
    -- -- Log:table("pt3 table", pt3)

    

    -- -- DebugUtil.printTableRecursively(g_modManager, "g_modManager:: ", 0, 1)

    
    

    -- -- DebugUtil.printTableRecursively(_G, "_G:: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getmetatable(_G), "getmetatable(_G):: ", 0, 1)
    -- -- DebugUtil.printTableRecursively(getmetatable(_G).__index, "getmetatable(_G).__index:: ", 0, 1)


    self.pixelSpy = PixelSpy.new()
    
end

-- 2021-12-20 14:49 getmetatable(_G).__index:: g_modIsLoaded :: table: 0x02d1da394188
-- 2021-12-20 14:49 getmetatable(_G).__index::     FS22_DevTools :: true
-- 2021-12-20 14:49 getmetatable(_G).__index::     FS22_PowerTools :: true

local function quitGame(restart, hardReset)
    restart = restart or false
    hardReset = hardReset or false

    local success = pcall(function()
        if not hardReset and g_currentMission ~= nil then
            OnInGameMenuMenu()
            
        end

        RestartManager:setStartScreen(RestartManager.START_SCREEN_MAIN)

        local gameID = ""
        if restart and g_careerScreen ~= nil and g_careerScreen.currentSavegame ~= nil then
            gameID = g_careerScreen.currentSavegame.savegameIndex
        end

        doRestart(hardReset, "-autoStartSavegameId " .. gameID)
        
    end)

    if not success then
        Log:error("Failed to exit/restart game")
    end
end

DevToolsConsoleCommands = {
	softRestart = function (self)
		-- RestartManager:setStartScreen(RestartManager.START_SCREEN_MAIN)
		-- -- doRestart(false, "")
        -- g_gui:showGui("MainScreen")
        -- OnInGameMenuMenu()
        quitGame(true, false)
	end,
	hardReset = function (self)
		quitGame(true, true)
	end,

    extractTable = function (self, tableName)
        if tableName == nil then
            Log:error("tableName is mandatory")
            return nil
        end
        local actualTable = nil

        if tableName == "_G" then
            Log:debug("Getting global")
            actualTable = _G
        elseif tableName == "__G" then
            Log:debug("Getting true global")
            actualTable = DevTools.__g
        else
            -- Get table from global mod scope (sandbox)
            actualTable = _G[tableName]

            -- Get table from true global scope
            if actualTable == nil then
                actualTable = DevTools.__g[tableName]
            end

            -- Try to get table from mod environment
            if actualTable == nil then
                actualTable = DevTools.env[tableName]
            end

            -- Try to get table via loadstring/pcall method (supports multi level tables as A.B.C)
            if actualTable == nil then
                local __G = DevTools.__g
                local tableExtractFunction = loadstring("return " .. tableName)
                local success, tempTable = pcall(tableExtractFunction) -- First try with the regular environment

                if success then
                    actualTable = tempTable
                else
                    Log:debug("Trying fallback enviroment")
                    setfenv(tableExtractFunction, DevTools.__g)
                    success, tempTable = pcall(tableExtractFunction) -- First try with the regular environment
                end

                if success then
                    actualTable = tempTable
                else
                    Log:debug("Even loadstring/pcall method failed on table '%s'", tableName)
                end
            end

        end
        -- local x = loadstring(tableName)
		-- Log:table(tableName, x)
        -- local y = DevTools.__g[tableName]
		-- Log:table(tableName, y)
        -- local z = DevTools.env[tableName]
		-- Log:table(tableName, z)

        if actualTable == nil then
            Log:error("Table '%s' not found", tableName)
        end

        return actualTable
	end,

    printTable = function (self, tableName, maxDepth)
        local USAGE = "USAGE: # devToolsPrintTable tableName [maxDepth]"
        if tableName == nil then
            Log:error("tableName is mandatory")
            return USAGE
        end
        maxDepth = tonumber(maxDepth)
        maxDepth = maxDepth or 1
        
        if type(maxDepth) ~= "number" then
            Log:error("maxDepth must be a number")
            return USAGE
        end

        local actualTable = self:extractTable(tableName)

        if actualTable ~= nil then
            Log:table(tableName, actualTable, maxDepth)
        end
	end,

    saveTable = function (self, tableName, filename, maxDepth, includeMods)
        local USAGE = "USAGE: # devToolsSaveTable tableName filename [maxDepth]"
        if tableName == nil then
            Log:error("tableName is mandatory")
            return USAGE
        end

        -- local maxDepth = 4
        maxDepth = tonumber(maxDepth)
        maxDepth = maxDepth or 2

        -- local includeModsOnGlobal = false
        includeMods = includeMods or false
        -- maxDepth = maxDepth or 1

        Log:var("Saving table", tableName)

        Log:var("filename", filename)

        -- Log:var("g_currentModSettingsDirectory", g_currentModSettingsDirectory)
        -- Log:var("l_currentModSettingsDirectory", l_currentModSettingsDirectory)

        if not string.endsWith(filename, ".lua") then
            filename = filename .. ".lua"
        end

        local filePath = Utils.getFilenameFromPath(filename)

        if filePath == nil then
            filePath = filename
        end

        -- g_modSettingsDirectory
        filePath = l_currentModSettingsDirectory .. filePath

        Log:var("filePath", filePath)


        -- g_modManager.nameToMod
        -- g_modManager.mods
        -- g_modManager.validMods

        local ignoredTables = {}
        -- local ignoredTableNames = {}

        -- Log:table("g_modManager.validMods", g_modManager.validMods)
        local actualTable = self:extractTable(tableName)

        local __G = DevTools.__g
        local isTrueGlobal = (actualTable == __G)

        Log:var("isTrueGlobal", isTrueGlobal)

        -- Omit mods from the global table
        if isTrueGlobal and not includeMods then
            Log:debug("Scanning %d valid mods", #g_modManager.validMods)
            for key, mod in ipairs(g_modManager.validMods) do
                -- Log:debug("%s", mod.modName)
                
                ignoredTables[mod.modName] = true
            end

            Log:debug("Scanning %d mods", #g_modManager.mods)
            -- Log:table("g_modManager.mods", g_modManager.mods)
            for key, mod in ipairs(g_modManager.mods) do
                -- Log:debug("%s", mod.modName)

                if ignoredTables[mod.modName] ~= true then
                    ignoredTables[mod.modName] = true
                else
                    Log:debug("Mod '%s' already added to the list", mod.modName)
                end
                
                
            end

            ignoredTables["g_modEventListeners"] = true
            ignoredTables["g_modIsLoaded"] = true
            ignoredTables["g_modNameToDirectory"] = true
            

        end


        -- Log:table("g_modManager.nameToMod", g_modManager.nameToMod)

        -- for key, mod in ipairs(g_modManager.mods) do
        --     Log:debug("%s", tostring(mod))
            
        --     table.insert(ignoredTables, tostring(mod))
        -- end

        -- Utils.getFilenameFromPath

        -- g_modSettingsDirectory = modSettingsDir

		createFolder(l_currentModSettingsDirectory)

        Log:debug("Saving '%s' to '%s' using maxDepth '%s' and allowing mods %s", tableName, filePath, maxDepth, tostring(includeMods))

        if actualTable ~= nil then
            Log:saveTable(filePath, tableName, actualTable, maxDepth, ignoredTables)

            if fileExists(filePath) then
                Log:info("Saved '%s' to '%s' using maxDepth '%s' and allowing mods %s", tableName, filePath, maxDepth, tostring(includeMods))
            else
                Log:error("Failed to save '%s' to '%s'", tableName, filePath)
            end
        else
            Log:error("Table '%s' not found", tableName)
        end

	end,    
    testCommand = function (self)
        local orig = getUserProfileAppPath() .. "log.txt"
        local new = getUserProfileAppPath() .. "logX.txt"
        setFileLogName(new)
        print("test")
        DevTools.__g.deleteFile(orig)
        setFileLogName(orig)
        print("test2")
    end,
    clearLog = function (self)
        local originalLogFile = getUserProfileAppPath() .. "log.txt"
        local tempLogFile = getUserProfileAppPath() .. "log.txt.tmp"
        local backupLogFile = getUserProfileAppPath() .. "log.bak"
        copyFile(originalLogFile, backupLogFile, true)
        setFileLogName(tempLogFile) -- Temporarily redirect the log to a new file
        DevTools.__g.deleteFile(originalLogFile) -- Delete orignal log (via superglobal)
        setFileLogName(originalLogFile) -- Restore original log
        print("Log cleared")
    end,
    exitGame = function (self)
        Log:debug("Exit game")
        doExit()
    end,
}

local __G = DevTools.__g


-- __G.doExit = Utils.overwrittenFunction(__G.doExit, function (self, superFunc)
--     print("Oh no nu åker vi")
--     superFunc()
-- end)

local oldRequestExit = DevTools.__g.requestExit
DevTools.__g.requestExit = function (...)
    print("Nu kör vi en req exit")
    oldRequestExit(...)
end

local oldRestartApplication = DevTools.__g.restartApplication
DevTools.__g.restartApplication = function (...)
    print("Nu kör vi en faktisk restart")
    oldRestartApplication(...)
end

DebugHelper:interceptDecode(DevTools.__g, "requestExit")
DebugHelper:interceptDecode(DevTools.__g, "doExit")
DebugHelper:interceptDecode(DevTools.__g, "restartApplication")
DebugHelper:interceptDecode(DevTools.__g, "doRestart")

local oldExit = DevTools.__g.doExit
DevTools.__g.doExit = function (...)
    print("Oh no nu åker vi")
    oldExit(...)
end

local oldRestart = __G.doRestart
__G.doRestart = function (...)
    print("Nu gör vi en restart")
    -- Log:var("args", args)
    Log:table("args", {...})
    -- print_r(args )
    oldRestart(...)
end



-- addConsoleCommand("gsScriptCommandsList", "Lists script-based console commands. Use 'help' to get all commands", "consoleCommandListCommands", nil)

safeAddConsoleCommand("rr", "Restart the game", "hardReset", DevToolsConsoleCommands)
safeAddConsoleCommand("r", "Restart the game (soft restart)", "softRestart", DevToolsConsoleCommands)

function DevTools:draw(dt)
    self.pixelSpy:drawOverlay("compactionMap")
end

function DevTools:beforeLoadMap()
    safeAddConsoleCommand("rr", "Restart the game", "hardReset", DevToolsConsoleCommands)
    safeAddConsoleCommand("r", "Restart the game", "softRestart", DevToolsConsoleCommands)

    addConsoleCommand("leave", "", "softRestart", SystemConsoleCommands)

    

    -- addConsoleCommand("rr", "Restart the game", "hardReset", DevToolsConsoleCommands)
    -- addConsoleCommand("r", "Restart the game", "softRestart", DevToolsConsoleCommands)
    addConsoleCommand("dtTable", "Print table", "printTable", DevToolsConsoleCommands)
    addConsoleCommand("devToolsPrintTable", "Print table to log", "printTable", DevToolsConsoleCommands)
    addConsoleCommand("devToolsSaveTable", "Save table to file", "saveTable", DevToolsConsoleCommands)

    addConsoleCommand("dtTest", "", "testCommand", DevToolsConsoleCommands)
    addConsoleCommand("devToolsClearLog", "", "clearLog", DevToolsConsoleCommands)
    addConsoleCommand("cls", "", "clearLog", DevToolsConsoleCommands)

    addConsoleCommand("q", "", "exitGame", DevToolsConsoleCommands)

    
end

-- SystemConsoleCommands.softRestart = Utils.overwrittenFunction(SystemConsoleCommands.softRestart, function(self, superFunc)
--     print("Oh no, restaring")

--     superFunc(self)

-- end)


function DevTools:initMission()

    -- addConsoleCommand("gsExtraContentSystemCreateKeysAll", "Create keys for all items", "consoleCommandCreateKeysAll", g_extraContentSystem)
    -- addConsoleCommand("gsExtraContentSystemUnlockAll", "Unlocks all items", "consoleCommandUnlockAll", g_extraContentSystem)


    -- addConsoleCommand("e", "Exit the game to the menu", "consoleCommandLeaveGame", self)
    -- addConsoleCommand("r", "Restart the game", "consoleCommandRestartGame", self)
    -- addConsoleCommand("rr", "", "softRestart", SystemConsoleCommands)
    -- addConsoleCommand("r", "", "softRestart", SystemConsoleCommands)

    --enableDevelopmentControls()
    --toggleShowFPS
    --toggleStatsOverlay
end

function DevTools:debugMultiplayerInfo()
    local debugInfo = {
        isMultiplayerGame = self:getIsMultiplayer(),
        isServer = self:getIsServer(),
        isClient = self:getIsClient(),
        isDedicatedServer = self:getIsDedicatedServer(),
        g_dedicatedServer = (g_dedicatedServer ~= nil),
        isMasterUser = self:getIsMasterUser(),
        hasFarmAdminAccess = self:getHasFarmAdminAccess(),
        isValidFarmManager = self:getIsValidFarmManager(),
    }


    DebugUtil.printTableRecursively(debugInfo, "Debub info:: ", 2)    
end

function DevTools:consoleCommandLeaveGame()
    removeConsoleCommand("e")
    -- RestartManager.restarting = false
    doRestart(true, "-restart")
    -- -- g_gui:showGui("MainScreen")
    -- RestartManager:handleRestart()

    -- g_careerScreen.savegameList:setSelectedIndex(tonumber(0), true)
    -- g_careerScreen.savegameList.selectedIndex = nil
    -- g_careerScreen.currentSavegame = nil
    -- g_currentMission = nil

    -- OnInGameMenuMenu()
end

function DevTools:consoleCommandRestartGame()
    removeConsoleCommand("r")
    doRestart(true, "")
end


function ExtraContentSystem:getIsItemIdUnlocked(id)
    return true
end


local orig = getUserProfileAppPath() .. "log.txt"
local new = getUserProfileAppPath() .. "log.txt.bak"
copyFile(orig, new, true)