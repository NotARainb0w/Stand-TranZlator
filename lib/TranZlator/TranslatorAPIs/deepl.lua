-- scripts/lib/TranZlator/TranslatorAPIs/deepl.lua

-- Load necessary library
local json = require('json')

-- Function to translate via DeepL API
function translateWithDeepL(text, target, apiKey, callback)
    local url = string.format("https://api-free.deepl.com/v2/translate?auth_key=%s&text=%s&target_lang=%s", apiKey, encode_url(text), target)
    async_http.init(url, nil, function(body, headers, status_code)
        if status_code == 200 then
            local response = json.decode(body)
            if response and response.translations and response.translations[1] and response.translations[1].text then
                callback(response.translations[1].text)
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
