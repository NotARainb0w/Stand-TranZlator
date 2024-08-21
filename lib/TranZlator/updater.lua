-- scripts/lib/TranZlator/updater.lua

-- URLs for the scripts on GitHub
local update_base_url_root = "raw.githubusercontent.com"
local update_base_url_path_root = "/Cracky0001/Stand-TranZlator/main/"
local update_base_url_path_lib = "lib/TranZlator/"
local update_base_url_path_apis = update_base_url_path_lib .. "TranslatorAPIs/"


-- Function to check if a URL exists
local function url_exists(host, path, callback)
    async_http.init(host, path, function(body, headers, status_code)
        if status_code == 200 then
            callback(true)
        else
            callback(false)
        end
    end, function()
        callback(false)
    end)
    async_http.dispatch()
end

-- Function to download content from a URL
local function download_file(host, path, save_path, callback)
    async_http.init(host, path, function(body, headers, status_code)
        if status_code == 200 then
            local file = io.open(save_path, "w")
            if file then
                file:write(body)
                file:close()
                callback(true)
            else
                callback(false)
            end
        else
            callback(false)
        end
    end, function()
        callback(false)
    end)
    async_http.dispatch()
end

-- Function to check if all required files exist
local function check_files_exist()
    local script_dir = filesystem.scripts_dir()
    local files_to_check = {
        "TranZlator.lua",
        "lib/TranZlator/logic.lua",
        "lib/TranZlator/menu.lua",
        "lib/TranZlator/welcomegraphic.lua",
        "lib/TranZlator/TranslatorAPIs/deepl.lua",
        "lib/TranZlator/TranslatorAPIs/google.lua"
    }

    for _, file_path in ipairs(files_to_check) do
        local file = io.open(script_dir .. "/" .. file_path, "r")
        if not file then
            return false
        else
            file:close()
        end
    end
    return true
end

-- Function to compare version numbers
local function compare_versions(version_a, version_b)
    local major_a, minor_a, patch_a = version_a:match("(%d+)%.(%d+)%.(%d+)")
    local major_b, minor_b, patch_b = version_b:match("(%d+)%.(%d+)%.(%d+)")

    if tonumber(major_a) > tonumber(major_b) then
        return true
    elseif tonumber(major_a) == tonumber(major_b) then
        if tonumber(minor_a) > tonumber(minor_b) then
            return true
        elseif tonumber(minor_a) == tonumber(minor_b) then
            return tonumber(patch_a) > tonumber(patch_b)
        end
    end

    return false
end

-- Function to check if all necessary URLs exist
local function check_urls_exist(callback)
    local files_to_check = {
        update_base_url_path_root .. "TranZlator.lua",
        update_base_url_path_root .. update_base_url_path_lib .. "logic.lua",
        update_base_url_path_root .. update_base_url_path_lib .. "menu.lua",
        update_base_url_path_root .. update_base_url_path_lib .. "welcomegraphic.lua",
        update_base_url_path_root .. update_base_url_path_apis .. "deepl.lua",
        update_base_url_path_root .. update_base_url_path_apis .. "google.lua"
    }

    local all_exist = true
    local checked = 0

    for _, path in ipairs(files_to_check) do
        url_exists(update_base_url_root, path, function(exists)
            checked = checked + 1
            if not exists then
                all_exist = false
            end
            if checked == #files_to_check then
                callback(all_exist)
            end
        end)
    end
end

-- Function to perform the update
local function perform_update()
    local files_to_update = {
        ["TranZlator.lua"] = "TranZlator.lua",
        ["logic.lua"] = "lib/TranZlator/logic.lua",
        ["menu.lua"] = "lib/TranZlator/menu.lua",
        ["welcomegraphic.lua"] = "lib/TranZlator/welcomegraphic.lua",
        ["deepl.lua"] = "lib/TranZlator/TranslatorAPIs/deepl.lua",
        ["google.lua"] = "lib/TranZlator/TranslatorAPIs/google.lua"
    }

    local script_dir = filesystem.scripts_dir()
    local errors = {}

    local function check_completion()
        if #errors > 0 then
            util.toast("Failed to update the following files: " .. table.concat(errors, ", "), TOAST_ALL)
        else
            util.toast("All files updated successfully! Please restart the script.", TOAST_ALL)
        end
    end

    local files_checked = 0

    for file_name, local_path in pairs(files_to_update) do
        local host = update_base_url_root
        local path = file_name == "TranZlator.lua" and update_base_url_path_root .. file_name or (file_name == "deepl.lua" or file_name == "google.lua") and update_base_url_path_root .. update_base_url_path_apis .. file_name or update_base_url_path_root .. update_base_url_path_lib .. file_name
        local save_path = script_dir .. "/" .. local_path

        download_file(host, path, save_path, function(success)
            files_checked = files_checked + 1
            if not success then
                table.insert(errors, local_path)
            end
            if files_checked == #files_to_update then
                check_completion()
            end
        end)
    end
end

-- Function to check and compare versions
local function check_for_update(current_version)
    local path = update_base_url_path_root .. "TranZlator.lua"
    async_http.init(update_base_url_root, path, function(body, headers, status_code)
        if status_code == 200 then
            local remote_version = body:match("verNum%s*=%s*\"(%d+%.%d+%.%d+)\"")
            
            if remote_version then
                if compare_versions(remote_version, current_version) then
                    perform_update()
                elseif compare_versions(current_version, remote_version) then
                    util.toast("[TranZlator]\n" .. "You are using a developer version (" .. current_version .. ") that has not yet been released.")
                else
                    if not check_files_exist() then
                        perform_update()
                    else
                        util.toast("[TranZlator]\n" .. "You are using the latest version. (" .. current_version .. ")")
                    end
                end
            else
                util.toast("Failed to check the version. Version could not be extracted from the response.")
            end
        else
            util.toast("Failed to check the version - HTTP Status: " .. tostring(status_code))
        end
    end, function()
        util.toast("Failed to check the version.")
    end)
    async_http.dispatch()
end

-- Main function to start the update process
local function main(current_version)
    check_urls_exist(function(all_exist)
        if all_exist then
            check_for_update(current_version)
        else
            util.toast("Some files could not be found. Please check the URLs.", TOAST_ALL)
        end
    end)
end

-- Export the function so that it can be called from TranZlator.lua
return {
    check_for_update = main
}