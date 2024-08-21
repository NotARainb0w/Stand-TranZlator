-- TranzLator.lua

-------------------------------------
-- TranZlator by Cracky
-- Version: 1.2.6
-- GitHub: https://github.com/Cracky0001/Stand-TranZlator
-------------------------------------

-- Load necessary libraries and modules
util.require_natives("natives-3095a")
require('json')  
require('lib.TranZlator.menu')
require('lib.TranZlator.welcomegraphic')
require('lib.TranZlator.logic')

-- Load the updater functions
local updater = require('lib.TranZlator.updater')

-- Global variables
verNum = "1.2.6"  -- The current version of the script
targetLang = "en"
autoTranslateEnabled = true
selectedAPI = "Google"
deepLApiKey = ""
translateToTeamChat = false  -- New variable for the Team Chat setting
consoleOutputEnabled = true  -- Enable or disable console output
consolePrefixEnabled = true  -- Enable or disable the prefix in console output
showChatterNameInConsole = true  -- Show the name of the chatter in console output

-- Main function to initialize the script
local function main()
    display_welcome_graphic()
    initialize_log_and_check_internet()
    if updater and updater.check_for_update then  -- Ensure that updater exists and contains the function
        updater.check_for_update(verNum)  -- Start the update process
    else
        util.toast("Updater module could not be loaded.", TOAST_ALL)
    end
end

-- Execute the main function
main()
