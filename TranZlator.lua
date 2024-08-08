-- main.lua

-------------------------------------
-- TranZlator by Cracky
-- Version: 1.2 (Pre)
-- GitHub: https://github.com/Cracky0001/Stand-TranZlator
-------------------------------------

-- Load necessary libraries and modules
util.require_natives("natives-3095a")
require('json')  
require('lib.TranZlator.menu')
require('lib.TranZlator.welcomegraphic')
require('lib.TranZlator.logic')

-- Global variables
verNum = "1.2 (Pre)"
targetLang = "en"
autoTranslateEnabled = true
selectedAPI = "Google"
deepLApiKey = ""
translateToTeamChat = false  -- Neue Variable für die Team-Chat-Einstellung

-- Main function to initialize the script
local function main()
    display_welcome_graphic()
    initialize_log_and_check_internet()
end

-- Execute the main function
main()
