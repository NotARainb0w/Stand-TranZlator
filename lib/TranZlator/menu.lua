-- scripts/lib/TranZlator/menu.lua

-- Main Menu for TranZlator
local rootMenu = menu.my_root()

-- Categories
local settingsCategory = menu.list(rootMenu, "Settings", {}, "Configure the TranZlator settings.")
local translationSettingsCategory = menu.list(settingsCategory, "Translation Settings", {}, "Manage translation settings.")
local apiSettingsCategory = menu.list(settingsCategory, "API Settings", {}, "Configure API keys and settings.")
local displaySettingsCategory = menu.list(settingsCategory, "Display Settings", {}, "Manage display options for notifications.")
local customMessageCategory = menu.list(rootMenu, "Custom Message", {}, "Translate and send a custom message.")  -- Moved to root
local credits = menu.list(rootMenu, "Credits", {}, "Visit Cracky's LinkHub for more scripts and resources.")

-- Translation Settings
local languages = {
    {code="en", name="English"},
    {code="zh", name="Chinese"},
    {code="hi", name="Hindi"},
    {code="es", name="Spanish"},
    {code="fr", name="French"},
    {code="ar", name="Arabic"},
    {code="bn", name="Bengali"},
    {code="ru", name="Russian"},
    {code="pt", name="Portuguese"},
    {code="id", name="Indonesian"},
    {code="ur", name="Urdu"},
    {code="de", name="German"},
    {code="ja", name="Japanese"},
    {code="sw", name="Swahili"},
    {code="mr", name="Marathi"},
    {code="te", name="Telugu"},
    {code="tr", name="Turkish"},
    {code="ta", name="Tamil"},
    {code="vi", name="Vietnamese"},
    {code="ko", name="Korean"}
}

local langNames = {}
for i, lang in ipairs(languages) do
    table.insert(langNames, lang.name)
end

menu.toggle(translationSettingsCategory, "Enable/Disable Translation", {"translate"}, "Enable or disable automatic translation of chat messages", function() return autoTranslateEnabled end, function(value)
    autoTranslateEnabled = value
end)

menu.list_select(translationSettingsCategory, "Target Language", {}, "Select the target language", langNames, 1, function(index)
    targetLang = languages[index].code
end)

menu.list_select(translationSettingsCategory, "Select Translation API", {}, "Choose between Google Translate and DeepL", {"Google", "DeepL"}, 1, function(index)
    selectedAPI = index == 1 and "Google" or "DeepL"
end)

-- API Settings
menu.text_input(apiSettingsCategory, "DeepL API Key", {"deeplapikey"}, "Enter your DeepL API key", function(value)
    deepLApiKey = value
end)

-- Display Settings
local displayOptions = {"Stand Notify", "GTA Notify", "Both"}
menu.list_select(displaySettingsCategory, "Display Notification In", {}, "Select where to display the translated notification", displayOptions, 1, function(index)
    displayOption = displayOptions[index]
end)

-- Custom Message
local customMessageTargetLang = "en"
local chatOptions = {"All Chat", "Team Chat"}
local selectedChatOption = 1  -- Default to "Team Chat"

menu.list_select(customMessageCategory, "Target Language", {}, "Select the target language for the custom message", langNames, 1, function(index)
    customMessageTargetLang = languages[index].code
end)

-- Menu option to select the target chat
menu.list_select(customMessageCategory, "Send Message To", {}, "Select whether to send the message to Team Chat or All Chat", {"Team Chat", "All Chat"}, 1, function(index)
    selectedChatOption = index
end)

-- Menu option to input the message
menu.text_input(customMessageCategory, "Message", {"transmessage"}, "Enter the message to be translated and sent", function(value)
    -- The value `selectedChatOption` is 1 for Team Chat and 2 for All Chat
    local send_to_all_chat = (selectedChatOption == 2)  -- If 2, send to All Chat, otherwise Team Chat
    send_translated_message(value, customMessageTargetLang, send_to_all_chat)
end)

-- Credits
menu.hyperlink(credits, "Cracky's LinkHub", "https://home.cracky-drinks.vodka", "Visit Cracky's LinkHub for more scripts and resources.")

menu.hyperlink(credits, "TranZlator on GitHub", "https://github.com/Cracky0001/Stand-TranZlator", "Visit the GitHub repository for TranZlator.")
