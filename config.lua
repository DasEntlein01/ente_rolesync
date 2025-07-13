Config = {}

Config.DiscordToken = ""
Config.DiscordGuildID = ""
Config.DefaultGroup = "user"

Config.Roles = {
    ["ROLEID"] = "INGAMEGROUP",
}

function Notify(player_id, msg, title, type, time)
    TriggerClientEvent('eierlecken:notify', player_id, type, msg, time, title)
end