-------------------------------------
-- TranZlator by Cracky
-- Version: 1.0
-- GitHub: https://github.com/Cracky0001/Stand-TranZlater
-------------------------------------

--------------------------------------------------
-- Load natives
--------------------------------------------------
util.require_natives("natives-3095a")

--------------------------------------------------
-- Load necessary libraries
--------------------------------------------------
local json = require('json')

--------------------------------------------------
-- Global variables
--------------------------------------------------
local verNum = "1.0"
local targetLang = "en"
local autoTranslateEnabled = true
--------------------------------------------------
-- Function to URL encode a string
--------------------------------------------------
function encode_url(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str    
end

--------------------------------------------------
-- Function to translate via Google Translate API
---------------------------------------------------
function translateText(text, target, callback)
    local url = string.format("https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&q=%s", target, encode_url(text))
    async_http.init(url, nil, function(body, headers, status_code)
        if status_code == 200 then
            local response = json.decode(body)
            if response and response[1] and response[1][1] and response[1][1][1] then
                callback(response[1][1][1])
            else
                callback("Error: Invalid response from translation service")
            end
        else
            callback("Error in translation: HTTP status " .. tostring(status_code))
        end
    end, function(reason)
        callback("Error: Request could not be sent. Reason: " .. reason)
    end)
    async_http.dispatch()
end

--------------------------------------------------
-- Function to get player name by player ID
--------------------------------------------------
local function getPlayerName(player_id)
    return PLAYER.GET_PLAYER_NAME(player_id)
end

--------------------------------------------------
-- Function to draw a solid background
--------------------------------------------------
local function draw_background(x, y, width, height, color)
    directx.draw_rect(x, y, width, height, color)
end

--------------------------------------------------
-- Function to display a welcome graphic. Damn, i hate this function.
--------------------------------------------------
local function display_welcome_graphic()
    local display_duration = 3000 
    local start_time = util.current_time_millis()

    while util.current_time_millis() - start_time < display_duration do
        -- Draw solid background rectangle
        draw_background(0.435, 0.46, 0.13, 0.1, {r = 0.0, g = 0.0, b = 0.0, a = 1})

        -- Draw welcome text
        directx.draw_text(0.5, 0.49, "TranZlator", 5, 1.2, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)
        directx.draw_text(0.5, 0.515, "Version"  .. verNum, 5, 0.8, {r = 0, g = 1.0, b = 0, a = 1.0}, true)
        directx.draw_text(0.5, 0.54, "Created by Cracky", 5, 0.6, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)

        util.yield()
    end
end

--------------------------------------------------
-- Menu for TranZlator
--------------------------------------------------
local rootMenu = menu.my_root()
local settingsCategory = menu.list(rootMenu, "TranZlator Settings", {})

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

--------------------------------------------------
-- Function to handle chat messages
--------------------------------------------------
chat.on_message(function(sender, team, message)
    local sender_name = getPlayerName(sender)
    local formatted_message = string.format("[%s] %s: %s", team, sender_name, message)

    if autoTranslateEnabled then
        translateText(message, targetLang, function(translatedMessage)
            local displayMessage = string.format("[TranZlated] %s: %s", sender_name, translatedMessage)
            util.toast(displayMessage, TOAST_ALL)  -- Display the translated message as a toast notification
        end)
    end
end)

--------------------------------------------------
-- Initialize log message and check internet access
--------------------------------------------------
local function initialize_log_and_check_internet()
    async_http.init("https://www.google.com", "/", function(body, headers, status_code)
        if status_code ~= 200 then
            util.toast("Enable internet connection for this script!")
            while true do
                util.toast("Enable internet connection for this script!", TOAST_ALL)
                util.yield(100)  -- Repeat every 100ms
            end
        else
            util.toast("Chat logging initialized.")
        end
    end, function(reason)
        util.toast("Enable internet connection for this script!")
        while true do
            util.toast("Enable internet connection for this script!", TOAST_ALL)
            util.yield(100)  -- Repeat every 100ms
        end
    end)
    async_http.dispatch()
end

--------------------------------------------------
-- Main function to initialize the script
--------------------------------------------------
local function main()
    display_welcome_graphic()
    initialize_log_and_check_internet()
end

--------------------------------------------------
-- Execute the main function
--------------------------------------------------
main()
