-- Load the necessary native functions
util.require_natives("natives-3095a")

local json = require('json')

local targetLang = "en"
local autoTranslateEnabled = true
local showOriginalText = false

-- Directory and file paths
local scriptHome = filesystem.scripts_dir() .. "/TranslatorPro/"
local debug_file_path = scriptHome .. "debug.txt"
local chat_log_file_path = scriptHome .. "chat_log.txt"

-- Ensure directory exists
function create_directory(path)
    if not filesystem.exists(path) then
        filesystem.mkdir(path)
    end
end

create_directory(scriptHome)

-- Function to URL encode a string
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

-- Function to translate text using Google Translate API
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

-- Function to get player name by player ID
local function getPlayerName(player_id)
    return PLAYER.GET_PLAYER_NAME(player_id)
end

-- Function to log messages to a file
function log_to_file(file_path, message)
    local file = io.open(file_path, "a")
    if file then
        file:write("[" .. os.date("%Y-%m-%d %X") .. "] " .. message .. "\n")
        file:flush()
        file:close()
    end
end

-- Function to log debug messages to a file
function log_debug(message)
    log_to_file(debug_file_path, message)
end

-- Function to log chat messages to a file
function log_chat(player_name, message)
    local log_message = player_name .. ": " .. message
    log_to_file(chat_log_file_path, log_message)
end

-- Adding category for Translator Pro settings
local rootMenu = menu.my_root()
local settingsCategory = menu.list(rootMenu, "Translator Pro Settings", {})

-- Adding menu entries in the Translator Pro settings category
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

menu.list_select(settingsCategory, "Target Language", {}, "Select the target language", langNames, 1, function(index)
    targetLang = languages[index].code
end)

menu.toggle(settingsCategory, "Automatic Translation", {}, "Enable or disable automatic translation of chat messages", function() return autoTranslateEnabled end, function(value)
    autoTranslateEnabled = value
end)

menu.toggle(settingsCategory, "Show Original Text", {}, "Show the original text along with the translation", function() return showOriginalText end, function(value)
    showOriginalText = value
end)

-- Function to handle chat messages
chat.on_message(function(sender, team, message)
    local sender_name = getPlayerName(sender)
    local formatted_message = string.format("[%s] %s: %s", team, sender_name, message)

    -- Log debug information
    log_debug("Chat message received - Player: " .. sender_name .. ", Message: " .. message)

    if autoTranslateEnabled then
        translateText(message, targetLang, function(translatedMessage)
            local displayMessage
            if showOriginalText then
                displayMessage = string.format("[Translated] %s (Original: %s)", translatedMessage, message)
            else
                displayMessage = string.format("[Translated] %s", translatedMessage)
            end
            util.toast(displayMessage, TOAST_ALL)  -- Display the translated message as a toast notification
            log_chat(sender_name, message)  -- Log the chat message
        end)
    end
end)

-- Function to initialize log message and check internet connectivity
local function initialize_log_and_check_internet()
    async_http.init("https://www.google.com", "/", function(body, headers, status_code)
        if status_code ~= 200 then
            util.toast("Enable internet connection for this script!")
            while true do
                util.toast("Enable internet connection for this script!", TOAST_ALL)
                util.yield(100)  -- Repeat 
            end
        else
            log_debug("Chat Log Initialized")
            util.toast("Chat logging initialized.")
        end
    end, function(reason)
        util.toast("Enable internet connection for this script!")
        while true do
            util.toast("Enable internet connection for this script!", TOAST_ALL)
            util.yield(100)  -- Repeat every 5 seconds
        end
    end)
    async_http.dispatch()
end

-- Main function to initialize the script
local function main()
    initialize_log_and_check_internet()
end

-- Execute the main function
main()
