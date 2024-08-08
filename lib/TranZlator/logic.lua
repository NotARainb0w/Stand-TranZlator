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

-- Function to display message in local feed with player icon
function display_message_in_local_feed(message, player_id)
    local prefix = "[TranZlated] "
    local full_message = prefix .. message

    -- Use the native function to display the message in local feed with player icon
    local icon_type = 1  -- Example icon type, you can change this as needed
    local icon_texture = "CHAR_DEFAULT"
    local player_name = getPlayerName(player_id)

    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(200)  -- Setting background color to light blue
    HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(full_message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(icon_texture, icon_texture, false, icon_type, player_name, "")
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)
end

-- Function to display message in local feed
function display_message_in_local_chat(message)
    local full_message = message
    chat.send_message(full_message, false, true, true)  -- Send only to the local player
end

-- Function to display message in Stand notify with header
function display_message_in_stand_notify(message)
    local header = "[TranZlator]"
    util.toast(header .. "\n" .. message, TOAST_ALL)
end

-- Function to handle chat messages
chat.on_message(function(sender, team, message)
    local sender_name = getPlayerName(sender)
    local formatted_message = string.format("%s: %s", sender_name, message)

    if autoTranslateEnabled then
        local translationCallback = function(translatedMessage)
            local displayMessage = translatedMessage  -- Only the translated message without the sender name
            if displayOption == "Stand Notify" or displayOption == "Both" then
                display_message_in_stand_notify(displayMessage)  -- Display the translated message in Stand notify with header
            end
            if displayOption == "GTA Notify" or displayOption == "Both" then
                display_message_in_local_feed(displayMessage, sender)  -- Display the translated message in the local feed with player icon
            end
        end

        if selectedAPI == "DeepL" and deepLApiKey ~= "" then
            translateWithDeepL(message, targetLang, deepLApiKey, translationCallback)
        else
            translateWithGoogle(message, targetLang, translationCallback)
        end
    end
end)

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
