QBCore = exports['qb-core']:GetCoreObject()

local activeTags = {}

RegisterCommand("tag", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local identifiers = GetPlayerIdentifiers(source)
    local playerRole = nil

    for _, id in pairs(identifiers) do
        if Config.AllowedUsers[id] then
            playerRole = Config.AllowedUsers[id]
            break
        end
    end

    if playerRole and Config.Roles[playerRole] then
        if activeTags[source] then
            TriggerClientEvent("hideTag", source)
            activeTags[source] = nil
        else
            TriggerClientEvent("displayTag", source, playerRole)
            activeTags[source] = true
        end
    else
        TriggerClientEvent("QBCore:Notify", source, "Nemáš oprávnění používat tento příkaz!", "error")
    end
end, false)

RegisterNetEvent("setAFKTag")
AddEventHandler("setAFKTag", function()
    local src = source
    if activeTags[src] then
        TriggerClientEvent("displayTag", src, "afk")
    end
end)

RegisterNetEvent("removeAFKTag")
AddEventHandler("removeAFKTag", function()
    local src = source
    if activeTags[src] then
        local identifiers = GetPlayerIdentifiers(src)
        local playerRole = nil

        for _, id in pairs(identifiers) do
            if Config.AllowedUsers[id] then
                playerRole = Config.AllowedUsers[id]
                break
            end
        end

        if playerRole then
            TriggerClientEvent("displayTag", src, playerRole)
        end
    end
end)
