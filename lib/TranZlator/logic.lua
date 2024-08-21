-- scripts/lib/TranZlator/logic.lua

-- Global settings
autoTranslateEnabled = true
displayOption = "Both"  -- By default, both notifications are shown
selectedAPI = "Google"  -- Default is Google Translate
targetLang = "en"  -- Default language is English
localMessagePrefix = "!"  -- Prefix to identify local messages

-- Function to URL-encode a string
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

-- Load specific translation logic
require('lib.TranZlator.TranslatorAPIs.google')
require('lib.TranZlator.TranslatorAPIs.deepl')

-- Function to get the player's name based on their player ID
function getPlayerName(player_id)
    return PLAYER.GET_PLAYER_NAME(player_id)
end

-- Function to get the local player ID
function getLocalPlayerID()
    return PLAYER.PLAYER_ID()
end

-- Function to display messages in the local feed
function display_message_in_local_feed(message, sender_name)
    local prefix = "[TranZlated] "
    local full_message = prefix .. message

    -- Use native function to display the message in the local feed with player icon
    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(200)  -- Set background color to light blue
    HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(full_message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT_WITH_CREW_TAG("CHAR_MP_STRIPCLUB_PR", "CHAR_MP_STRIPCLUB_PR", false, 4, sender_name, "", 1.0, "")
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)
end

-- Function to display messages in the Stand notification with a header
function display_message_in_stand_notify(sender_name, message)
    local header = "[TranZlator]"
    local full_message = string.format("%s: %s", sender_name, message)
    util.toast(header .. "\n" .. full_message, TOAST_ALL)
end

-- Function to log messages to the console
function log_message_to_console(message)
    util.log("[TranZlator] " .. message)
end

-- Function to process chat messages
function handle_chat_message(sender, team, message)
    local sender_name = getPlayerName(sender)

    -- Check if the message has the local prefix
    if string.sub(message, 1, string.len(localMessagePrefix)) == localMessagePrefix then
        -- Ignore this message as it was locally generated
        return
    end

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
            if displayOption == "Local Chat Only" then
                local full_message = localMessagePrefix .. translatedMessage  -- Add prefix to avoid reprocessing
                chat.send_message(full_message, true, true, false)  -- Display in local Team Chat only
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
        if displayOption == "Local Chat Only" then
            local full_message = localMessagePrefix .. translatedMessage  -- Add prefix to avoid reprocessing
            chat.send_message(full_message, true, true, true)  -- Display in local Team Chat only
        else
            chat.send_message(translatedMessage, true, true, true)  -- Send message to Team Chat
        end
        log_message_to_console(translatedMessage)
    end

    -- API choice check
    if selectedAPI == "DeepL" and deepLApiKey ~= "" then
        translateWithDeepL(message, target_language, deepLApiKey, translationCallback)
    else
        translateWithGoogle(message, target_language, translationCallback)
    end
end

-- Initialize log and check internet connection
function initialize_log_and_check_internet()
    async_http.init("https://www.google.com", "/", function(body, headers, status_code)
        if status_code ~= 200 then
            util.toast("Enable internet connection for this script!")
            while true do
                util.toast("Enable internet connection for this script!", TOAST_ALL)
                util.yield(100)  
            end
        else
            util.toast("Chat logging initialized.")
        end
    end, function(reason)
        util.toast("Enable internet connection for this script!")
        while true do
            util.toast("Enable internet connection for this script!", TOAST_ALL)
            util.yield(100)  
        end
    end)
    async_http.dispatch()
end

-- Register the chat message handler
chat.on_message(handle_chat_message)
