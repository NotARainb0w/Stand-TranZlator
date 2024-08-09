-- scripts/lib/TranZlator/logic.lua

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

-- Load specific translator logic
require('lib.TranZlator.TranslatorAPIs.google')
require('lib.TranZlator.TranslatorAPIs.deepl')

-- Function to get player name by player ID
function getPlayerName(player_id)
    return PLAYER.GET_PLAYER_NAME(player_id)
end

-- Function to display message in local feed
function display_message_in_local_feed(message, sender_name)
    local prefix = "[TranZlated] "
    local full_message = prefix .. message

    -- Use the native function to display the message in local feed with player icon
    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(200)  -- Setting background color to light blue
    HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(full_message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT_WITH_CREW_TAG("CHAR_MP_STRIPCLUB_PR", "CHAR_MP_STRIPCLUB_PR", false, 4, sender_name, "", 1.0, "")
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)
end

-- Function to display message in Stand notify with header
function display_message_in_stand_notify(sender_name, message)
    local header = "[TranZlator]"
    local full_message = string.format("%s: %s", sender_name, message)
    util.toast(header .. "\n" .. full_message, TOAST_ALL)
end

-- Function to log message to console
function log_message_to_console(message)
    util.log("[TranZlator] " .. message)
end

-- Function to handle chat messages
function handle_chat_message(sender, team, message)
    local sender_name = getPlayerName(sender)
    local formatted_message = string.format("[%s] %s: %s", team, sender_name, message)

    if autoTranslateEnabled then
        local translationCallback = function(translatedMessage)
            log_message_to_console(translatedMessage)
            if displayOption == "Stand Notify" or displayOption == "Both" then
                display_message_in_stand_notify(sender_name, translatedMessage)
            end
            if displayOption == "GTA Notify" or displayOption == "Both" then
                display_message_in_local_feed(translatedMessage, sender_name)
            end
        end

        if selectedAPI == "DeepL" and deepLApiKey ~= "" then
            translateWithDeepL(message, targetLang, deepLApiKey, translationCallback)
        else
            translateWithGoogle(message, targetLang, translationCallback)
        end
    end
end

-- Function to translate and send a custom message
function send_translated_message(message, target_language, send_to_all_chat)
    local translationCallback = function(translatedMessage)
        chat.send_message(translatedMessage, send_to_all_chat, true, false)  -- Send the translated message to the chat
        log_message_to_console(translatedMessage)
    end

    if selectedAPI == "DeepL" and deepLApiKey ~= "" then
        translateWithDeepL(message, target_language, deepLApiKey, translationCallback)
    else
        translateWithGoogle(message, target_language, translationCallback)
    end
end

-- Function to initialize log message and check internet access
function initialize_log_and_check_internet()
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

-- Register chat message handler
chat.on_message(handle_chat_message)
