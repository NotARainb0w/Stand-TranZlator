-- Menu.lua
-- Menu setup for TranZlator

--------------------------------------------------
-- Global variables
--------------------------------------------------
targetLang = "en"
autoTranslateEnabled = true
selectedAPI = "Google"
deepLApiKey = ""

--------------------------------------------------
-- Menu for TranZlator
--------------------------------------------------
local rootMenu = menu.my_root()
local settingsCategory = menu.list(rootMenu, "TranZlator Settings", {})
local apiKeysCategory = menu.list(rootMenu, "API Keys", {})

--------------------------------------------------
-- Add language selection to menu
--------------------------------------------------
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

--------------------------------------------------
-- Add settings to the menu
--------------------------------------------------
menu.list_select(settingsCategory, "Target Language", {}, "Select the target language", langNames, 1, function(index)
    targetLang = languages[index].code
end)

menu.toggle(settingsCategory, "Enable/Disable Translation", {"translate"}, "Enable or disable automatic translation of chat messages", function() return autoTranslateEnabled end, function(value)
    autoTranslateEnabled = value
end)

menu.list_select(settingsCategory, "Select Translation API", {}, "Choose between Google Translate and DeepL", {"Google", "DeepL"}, 1, function(index)
    selectedAPI = index == 1 and "Google" or "DeepL"
end)

menu.text_input(apiKeysCategory, "DeepL API Key", {"deeplapikey"}, "Enter your DeepL API key", function(value)
    deepLApiKey = value
end)
