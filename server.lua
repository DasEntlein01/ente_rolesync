ESX = exports["es_extended"]:getSharedObject()

local playerGroupCache = {}

function getDiscordIdFromPlayer(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, v in pairs(identifiers) do
        if string.sub(v, 1, 8) == "discord:" then
            return string.sub(v, 9)
        end
    end
    return nil
end

function checkUserRole(playerId, callback)
    local discordId = getDiscordIdFromPlayer(playerId)
    if not discordId then
        callback(Config.DefaultGroup)
        return
    end

    local url = "https://discord.com/api/v10/guilds/" .. Config.DiscordGuildID .. "/members/" .. discordId
    PerformHttpRequest(url, function(status, response, headers)
        if status ~= 200 then
            callback(Config.DefaultGroup)
            return
        end

        local success, data = pcall(json.decode, response)
        if not success or not data or not data.roles then
            callback(Config.DefaultGroup)
            return
        end

        for discordRole, ingameGroup in pairs(Config.Roles) do
            for _, role in pairs(data.roles) do
                if role == discordRole then
                    callback(ingameGroup)
                    return
                end
            end
        end

        callback(Config.DefaultGroup)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.DiscordToken,
        ["Content-Type"] = "application/json"
    })
end

function updatePlayerGroup(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    checkUserRole(playerId, function(newGroup)
        local currentGroup = xPlayer.getGroup()
        
        if currentGroup ~= newGroup then
            playerGroupCache[playerId] = newGroup
            xPlayer.setGroup(newGroup)
            
            if newGroup ~= "user" then
                Notify(playerId, "Deine Teamrolle wurde aktualisiert: " .. newGroup, "Teamrolle", "info", 5000)
            else
                Notify(playerId, "Deine IC-Rechte wurden dir entnommen, da du kein Teammitglied mehr bist!", "Teamrolle", "info", 5000)
            end
        end
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId)
    updatePlayerGroup(playerId)
    if not playerGroupCache[playerId] then
        playerGroupCache[playerId] = "user"
    end
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    playerGroupCache[playerId] = nil
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        for _, playerId in ipairs(GetPlayers()) do
            updatePlayerGroup(tonumber(playerId))
        end
    end
end)

-- Eigentlich unötig 

RegisterCommand("claimteamrole", function(source)
    local playerId = source
    updatePlayerGroup(playerId)
end, false)



-- UPDATE CHECK


CreateThread(function()
    Wait(500) -- Wait a few seconds after the resource starts

    local resourceName = GetCurrentResourceName()
    local localVersion = GetResourceMetadata(resourceName, 'version', 0)

    PerformHttpRequest("https://api.github.com/repos/DasEntlein01/ente_rolesync/releases/latest", function(statusCode, response, _)
        if statusCode ~= 200 then
            print("^1[⚠️] Failed to fetch the latest version from GitHub. Status Code: " .. statusCode .. "^0")
            return
        end

        local success, data = pcall(json.decode, response)
        if not success or not data or not data.tag_name then
            print("^1[❌] Failed to parse GitHub response.^0")
            return
        end

        local latestVersion = data.tag_name:gsub("^v", "")

        if localVersion ~= latestVersion then
            print("^3──────────────────────────────────────────────")
            print("^3🔔 ^1ente_rolesync Update Available!^3")
            print("^3──────────────────────────────────────────────")
            print("^3📌 Current Version: ^0" .. localVersion)
            print("^3🚀 Latest Version: ^0" .. latestVersion)
            print("^3🔗 Download Update: ^0https://github.com/DasEntlein01/ente_rolesync/releases/latest")
            print("^3──────────────────────────────────────────────")
        else
            print("^2──────────────────────────────────────────────")
            print("^2✅ ente_rolesync is up to date!")
            print("^2📦 Version: " .. localVersion)
            print("^2──────────────────────────────────────────────")
        end
    end, "GET", "", {
        ["User-Agent"] = "FiveM-Version-Checker"
    })
end)
