-- TranzLator.lua

-------------------------------------
-- TranZlator by Cracky
-- Version: 1.2.1 (Pre)
-- GitHub: https://github.com/Cracky0001/Stand-TranZlator
-------------------------------------

-- Load necessary libraries and modules
util.require_natives("natives-3095a")
require('json')  
require('lib.TranZlator.menu')
require('lib.TranZlator.welcomegraphic')
require('lib.TranZlator.logic')

-- Laden der Updater-Funktionen
local updater = require('lib.TranZlator.updater')

-- Global variables
verNum = "1.2.1"  -- Die aktuelle Version des Skripts
targetLang = "en"
autoTranslateEnabled = true
selectedAPI = "Google"
deepLApiKey = ""
translateToTeamChat = false  -- Neue Variable für die Team-Chat-Einstellung

-- Main function to initialize the script
local function main()
    display_welcome_graphic()
    initialize_log_and_check_internet()
    if updater and updater.check_for_update then  -- Sicherstellen, dass updater existiert und die Funktion enthält
        updater.check_for_update(verNum)  -- Startet den Update-Prozess
    else
        util.toast("Updater module could not be loaded.", TOAST_ALL)
    end
end

-- Execute the main function
main()
