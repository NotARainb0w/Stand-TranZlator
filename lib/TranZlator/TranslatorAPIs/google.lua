-- scripts/lib/TranZlator/TranslatorAPIs/google.lua

-- Load necessary library
local json = require('json')

-- Function to translate via Google Translate API
function translateWithGoogle(text, target, callback)
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
