-- scripts/lib/TranZlator/updater.lua

-- URLs zu den Skripten auf GitHub
local update_base_url_root = "raw.githubusercontent.com"
local update_base_url_path_root = "/Cracky0001/Stand-TranZlator/main/"
local update_base_url_path_lib = "/Cracky0001/Stand-TranZlator/main/lib/TranZlator/"

-- Funktion zum Überprüfen, ob eine URL existiert
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

-- Funktion zum Herunterladen von Inhalten von einer URL
local function download_file(host, path, save_path)
    async_http.init(host, path, function(body, headers, status_code)
        if status_code == 200 then
            local file = io.open(save_path, "w")
            if file then
                file:write(body)
                file:close()
                util.toast("Datei " .. save_path .. " erfolgreich aktualisiert!")
            else
                util.toast("Fehler beim Öffnen der Datei " .. save_path)
            end
        else
            util.toast("Fehler beim Herunterladen von " .. path .. " - HTTP Status: " .. tostring(status_code))
        end
    end, function()
        util.toast("Fehler beim Herunterladen von " .. path)
    end)
    async_http.dispatch()
end

-- Funktion zur Überprüfung und zum Vergleich der Version
local function check_for_update(current_version)
    local path = update_base_url_path_root .. "TranZlator.lua"
    async_http.init(update_base_url_root, path, function(body, headers, status_code)
        if status_code == 200 then
            -- Logge den gesamten Inhalt der heruntergeladenen Datei
            util.log("Response Body: " .. body)

            -- Extrahiere die Versionsnummer (nur numerischer Teil)
            local remote_version = body:match("verNum%s*=%s*\"(%d+%.%d+%.%d+)")

            if remote_version then
                util.log("Extracted remote version: " .. remote_version)
                if compare_versions(remote_version, current_version) then
                    util.toast("Neue Version gefunden: " .. remote_version .. ". Update wird durchgeführt...")
                    perform_update()
                elseif compare_versions(current_version, remote_version) then
                    util.toast("Du nutzt eine Entwicklerversion (" .. current_version .. "), die noch nicht veröffentlicht wurde.")
                else
                    if not check_files_exist() then
                        util.toast("Fehlende Datei entdeckt. Update wird durchgeführt...")
                        perform_update()
                    else
                        util.toast("Du verwendest die neueste Version.")
                    end
                end
            else
                util.toast("Fehler beim Überprüfen der Version. Version konnte nicht aus der Antwort extrahiert werden.")
                util.log("Regex konnte die Version nicht extrahieren.")
            end
        else
            util.toast("Fehler beim Überprüfen der Version - HTTP Status: " .. tostring(status_code))
        end
    end, function()
        util.toast("Fehler beim Überprüfen der Version.")
    end)
    async_http.dispatch()
end


-- Funktion zum Vergleich von Versionsnummern
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

-- Funktion zum Überprüfen, ob alle erforderlichen Dateien vorhanden sind
local function check_files_exist()
    local files_to_check = {
        "TranZlator.lua",
        "lib/TranZlator/logic.lua",
        "lib/TranZlator/menu.lua",
        "lib/TranZlator/welcomegraphic.lua",
        "lib/TranZlator/TranslatorAPIs/deepl.lua",
        "lib/TranZlator/TranslatorAPIs/google.lua"
    }

    for _, file_path in ipairs(files_to_check) do
        local file = io.open(util.get_script_path() .. "/" .. file_path, "r")
        if not file then
            return false  -- Datei fehlt
        else
            file:close()
        end
    end
    return true  -- Alle Dateien sind vorhanden
end

-- Funktion zum Überprüfen, ob alle benötigten URLs existieren
local function check_urls_exist(callback)
    local files_to_check = {
        update_base_url_path_root .. "TranZlator.lua",
        update_base_url_path_lib .. "logic.lua",
        update_base_url_path_lib .. "menu.lua",
        update_base_url_path_lib .. "welcomegraphic.lua",
        update_base_url_path_lib .. "TranslatorAPIs/deepl.lua",
        update_base_url_path_lib .. "TranslatorAPIs/google.lua"
    }

    local all_exist = true
    local checked = 0

    for _, path in ipairs(files_to_check) do
        url_exists(update_base_url_root, path, function(exists)
            checked = checked + 1
            if not exists then
                util.toast("Fehler: Datei nicht gefunden - " .. path, TOAST_ALL)
                all_exist = false
            end
            if checked == #files_to_check then
                callback(all_exist)
            end
        end)
    end
end

-- Funktion zum Durchführen des Updates
local function perform_update()
    local files_to_update = {
        ["TranZlator.lua"] = "TranZlator.lua",
        ["lib/TranZlator/logic.lua"] = "lib/TranZlator/logic.lua",
        ["lib/TranZlator/menu.lua"] = "lib/TranZlator/menu.lua",
        ["lib/TranZlator/welcomegraphic.lua"] = "lib/TranZlator/welcomegraphic.lua",
        ["lib/TranZlator/TranslatorAPIs/deepl.lua"] = "lib/TranZlator/TranslatorAPIs/deepl.lua",
        ["lib/TranZlator/TranslatorAPIs/google.lua"] = "lib/TranZlator/TranslatorAPIs/google.lua"
    }

    for file_path, local_path in pairs(files_to_update) do
        local host = update_base_url_root
        local path = file_path == "TranZlator.lua" and update_base_url_path_root .. file_path or update_base_url_path_lib .. file_path
        local save_path = util.get_script_path() .. "/" .. local_path
        download_file(host, path, save_path)
    end
end

-- Hauptfunktion zum Starten der Update-Prozedur
local function main(current_version)
    check_urls_exist(function(all_exist)
        if all_exist then
            check_for_update(current_version)
        else
            util.toast("Einige Dateien konnten nicht gefunden werden. Überprüfen Sie die URLs.", TOAST_ALL)
        end
    end)
end

-- Exportiere die Funktion, damit sie von TranZlator.lua aufgerufen werden kann
return {
    check_for_update = main
}
