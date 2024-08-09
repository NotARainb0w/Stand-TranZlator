-- scripts/lib/TranZlator/logic.lua

-- Globale Einstellungen
autoTranslateEnabled = true
displayOption = "Both"  -- Standardmäßig werden beide Benachrichtigungen angezeigt
selectedAPI = "Google"  -- Standardmäßig Google Translate
targetLang = "en"  -- Standardmäßig Englisch

-- Funktion zum URL-Encoding eines Strings
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

-- Laden der spezifischen Übersetzungslogik
require('lib.TranZlator.TranslatorAPIs.google')
require('lib.TranZlator.TranslatorAPIs.deepl')

-- Funktion, um den Spielernamen anhand der Spieler-ID zu erhalten
function getPlayerName(player_id)
    return PLAYER.GET_PLAYER_NAME(player_id)
end

-- Funktion, um die lokale Spieler-ID zu erhalten
function getLocalPlayerID()
    return PLAYER.PLAYER_ID()
end

-- Funktion, um Nachrichten im lokalen Feed anzuzeigen
function display_message_in_local_feed(message, sender_name)
    local prefix = "[TranZlated] "
    local full_message = prefix .. message

    -- Native Funktion verwenden, um die Nachricht im lokalen Feed mit Spieler-Icon anzuzeigen
    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(200)  -- Hintergrundfarbe auf Hellblau setzen
    HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(full_message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT_WITH_CREW_TAG("CHAR_MP_STRIPCLUB_PR", "CHAR_MP_STRIPCLUB_PR", false, 4, sender_name, "", 1.0, "")
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)
end

-- Funktion, um Nachrichten in der Stand-Benachrichtigung mit Überschrift anzuzeigen
function display_message_in_stand_notify(sender_name, message)
    local header = "[TranZlator]"
    local full_message = string.format("%s: %s", sender_name, message)
    util.toast(header .. "\n" .. full_message, TOAST_ALL)
end

-- Funktion zum Protokollieren von Nachrichten in der Konsole
function log_message_to_console(message)
    util.log("[TranZlator] " .. message)
end

-- Funktion zur Verarbeitung von Chat-Nachrichten
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

-- Funktion zum Übersetzen und Senden einer benutzerdefinierten Nachricht
function send_translated_message(message, target_language, send_to_all_chat)
    local translationCallback = function(translatedMessage)
        if send_to_all_chat then
            chat.send_message(translatedMessage, false, true, false)  -- Nachricht an All Chat senden
        else
            chat.send_message(translatedMessage, true, true, false)  -- Nachricht an Team Chat senden
        end
        log_message_to_console(translatedMessage)
    end

    -- Auswahl der Übersetzungs-API
    if selectedAPI == "DeepL" and deepLApiKey ~= "" then
        translateWithDeepL(message, target_language, deepLApiKey, translationCallback)
    else
        translateWithGoogle(message, target_language, translationCallback)
    end
end

-- Funktion zur Initialisierung der Protokollnachricht und Überprüfung des Internetzugangs
function initialize_log_and_check_internet()
    async_http.init("https://www.google.com", "/", function(body, headers, status_code)
        if status_code ~= 200 then
            util.toast("Enable internet connection for this script!")
            while true do
                util.toast("Enable internet connection for this script!", TOAST_ALL)
                util.yield(100)  -- Wiederholen alle 100 ms
            end
        else
            util.toast("Chat logging initialized.")
        end
    end, function(reason)
        util.toast("Enable internet connection for this script!")
        while true do
            util.toast("Enable internet connection for this script!", TOAST_ALL)
            util.yield(100)  -- Wiederholen alle 100 ms
        end
    end)
    async_http.dispatch()
end

-- Registriere den Chat-Nachrichten-Handler
chat.on_message(handle_chat_message)
