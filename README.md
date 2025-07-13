# Discord Role Sync for ESX

Dieses Script synchronisiert Discord-Rollen mit ESX-Spielergruppen in Echtzeit. Es überprüft alle 5 Sekunden, ob sich die Rollen der Spieler geändert haben und aktualisiert ihre Berechtigungen entsprechend.

## Features

- Automatische Synchronisierung von Discord-Rollen mit ESX-Gruppen
- Echtzeit-Überprüfung alle 5 Sekunden
- Manuelle Aktualisierung per Befehl
- Benachrichtigungssystem bei Rollenänderungen
- Cache-System für bessere Performance

## Voraussetzungen

- [ESX Framework](https://github.com/esx-framework/esx_core)
- Discord Bot -> [Discord Dev](https://discord.dev)
    - Bot muss Mitglied deines Discord-Servers sein

## Konfiguration

Erstelle oder aktualisiere die `config.lua` mit folgenden Werten:

```lua
Config = {}

Config.DiscordToken = ""
Config.DiscordGuildID = ""
Config.DefaultGroup = "user"

Config.Roles = {
    ["ROLEID"] = "INGAMEGROUP",
}

function Notify(player_id, msg, title, type, time)
    TriggerClientEvent('your:notify', player_id, type, msg, time, title)
end
```

## Befehle

- `/claimteamrole` - Aktualisiert manuell die eigene Teamrolle

## Nutzung

1. Der Bot überprüft automatisch alle 5 Sekunden die Rollen
2. Bei Serverjoin wird die Rolle einmalig überprüft
3. Bei Rollenänderungen erhält der Spieler eine Benachrichtigung

## Support

Bei Problemen öffne ein Issue auf GitHub oder kontaktiere uns auf unserem Discord-Server.

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
