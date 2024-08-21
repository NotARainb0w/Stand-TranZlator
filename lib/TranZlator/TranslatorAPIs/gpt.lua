-- scripts/lib/TranZlator/TranslatorAPIs/gpt.lua

-- Load JSON library with error handling
local success, json = pcall(require, "json")
if not success then
    util.toast("Failed to load JSON library. Ensure it is installed correctly.", TOAST_ALL)
    return
end

-- Global variable to store the GPT API key
local gptApiKey = ""

-- Function to set the GPT API key (used in the menu)
function setGptApiKey(key)
    gptApiKey = key or ""
end

-- Function to translate text using the GPT API
-- @param text: The text to be translated
-- @param targetLang: The target language code
-- @param callback: A function to be called with the translated text
function translateText(text, targetLang, callback)
    -- Check if the GPT API key is set
    if not gptApiKey or gptApiKey == "" then
        util.toast("GPT API Key is missing. Please provide a valid API Key.", TOAST_ALL)
        return
    end

    -- Prepare the prompt for the GPT API
    local prompt = string.format("Translate the following text to %s:\n\n%s", targetLang, text)

    -- Data to be sent in the API request
    local data = {
        model = "gpt-3.5-turbo",
        messages = {
            { role = "system", content = "You are a helpful assistant that translates text." },
            { role = "user", content = prompt }
        }
    }

    -- Convert the Lua table to a JSON string
    local jsonData = json.encode(data)

    -- Headers for the API request
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. gptApiKey
    }

    -- Initialize the asynchronous HTTP request to the GPT API
    async_http.init("https://api.openai.com", "/v1/chat/completions", function(response)
        -- Attempt to decode the JSON response
        local success, parsedResponse = pcall(json.decode, response)
        if not success then
            util.toast("Failed to parse GPT API response. Please check the API Key and response format.", TOAST_ALL)
            return
        end

        -- Check if the response contains the translated text
        if parsedResponse and parsedResponse.choices and #parsedResponse.choices > 0 then
            local translatedText = parsedResponse.choices[1].message.content
            callback(translatedText)
        else
            util.toast("Failed to translate using GPT. Check your API Key and internet connection.", TOAST_ALL)
        end
    end, function(error)
        -- Error handler for failed HTTP request
        util.toast("Error connecting to GPT API: " .. error, TOAST_ALL)
    end)

    -- Set the request method to POST and attach the headers
    async_http.set_post("application/json", jsonData)
    async_http.add_headers(headers)
    
    -- Dispatch the HTTP request
    async_http.dispatch()
end
