-- scripts/lib/TranZlator/menu.lua

-- Icons einbinden
local icons = require('lib.TranZlator.icons')

-- Sprachen einbinden
local languages = require('lib.TranZlator.languages')

-- Main Menu for TranZlator
local rootMenu = menu.my_root()

-- Categories
local settingsCategory = menu.list(rootMenu, "Settings", {}, "Configure the TranZlator settings.")
menu.divider(settingsCategory, "Display Settings")
--local displaySettingsCategory = menu.list(settingsCategory, "Display Settings", {}, "Manage display options for notifications.")

-- Bereitstellen der Icons für das Menü
local iconNames = {}
for i, icon in ipairs(icons) do
    table.insert(iconNames, icon.display)
end

-- Default selected icon
selectedIcon = icons[1].name

-- Other display settings
local displayOptions = {"Stand Notify", "GTA Notify", "Both", "Local Chat Only"}
menu.list_select(settingsCategory, "Display Notification In", {}, "Select where to display the translated notification", displayOptions, 1, function(index)
    displayOption = displayOptions[index]
end)
menu.list_select(settingsCategory, "GTA-Notification Icon", {}, "Select the icon for notifications", iconNames, 1, function(index)
    selectedIcon = icons[index].name
    name = icons[index].display
    
    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(200)
    HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("This is a preview of " .. name)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT_WITH_CREW_TAG(selectedIcon, selectedIcon, false, 4, "Preview", "", 1.0, "")
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)

end)

-- Translation Settings
menu.divider(settingsCategory, "Translation Settings")

local langNames = {}
for i, lang in ipairs(languages) do
    table.insert(langNames, lang.name)
end

menu.toggle(settingsCategory, "Enable/Disable Translation", {"translate"}, "Enable or disable automatic translation of chat messages", function() return autoTranslateEnabled end, function(value)
    autoTranslateEnabled = value
end)

menu.list_select(settingsCategory, "Target Language", {}, "Select the target language", langNames, 1, function(index)
    targetLang = languages[index].code
end)

menu.list_select(settingsCategory, "Select Translation API", {}, "Choose between Google Translate and DeepL", {"Google", "DeepL"}, 1, function(index)
    selectedAPI = index == 1 and "Google" or "DeepL"
end)

-- Message Translation
local messageTranslationCategory = menu.list(rootMenu, "Message Translation", {}, "Translate and send a message.")
menu.divider(messageTranslationCategory, "Message Translation")
local messageTranslationTargetLang = "en"
local chatOptions = {"All Chat", "Team Chat"}
local selectedChatOption = 1  -- Default to "Team Chat"

local userMessage = ""  -- Variable to store the user's message

menu.list_select(messageTranslationCategory, "Target Language", {}, "Select the target language for the message", langNames, 1, function(index)
    messageTranslationTargetLang = languages[index].code
end)

-- Menu option to select the target chat
menu.list_select(messageTranslationCategory, "Send Message To", {}, "Select whether to send the message to Team Chat or All Chat", {"Team Chat", "All Chat"}, 1, function(index)
    selectedChatOption = index
end)

-- Menu option to input the message
menu.text_input(messageTranslationCategory, "Message", {"transmessage"}, "Enter the message to be translated and sent", function(value)
    userMessage = value  -- Store the message in the variable
end)

-- Menu option to send the message
menu.action(messageTranslationCategory, "Send Message", {}, "Click to translate and send the message", function()
    if userMessage ~= "" then
        local send_to_all_chat = (selectedChatOption == 2)  -- If 2, send to All Chat, otherwise Team Chat
        send_translated_message(userMessage, messageTranslationTargetLang, send_to_all_chat)
    else
        util.toast("Please enter a message before sending.", TOAST_ALL)
    end
end)

-- Credits
local credits = menu.list(rootMenu, "Credits", {}, "Visit Cracky's LinkHub for more scripts and resources.")
menu.divider(credits, "Credits")
menu.hyperlink(credits, "Cracky's LinkHub", "https://home.cracky-drinks.vodka", "Visit Cracky's LinkHub for more scripts and resources.")
menu.hyperlink(credits, "TranZlator on GitHub", "https://github.com/Cracky0001/Stand-TranZlator", "Visit the GitHub repository for TranZlator.")
