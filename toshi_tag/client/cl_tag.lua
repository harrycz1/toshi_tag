local displayedTag = nil
local playerName = GetPlayerName(PlayerId()) -- Získá jméno hráče
local lastActionTime = GetGameTimer()
local isAFK = false

local RoleStyles = {
    ['mod'] = {icon = "🛠 MOD"},
    ['admin'] = {icon = "⚡ ADMIN"},
    ['god'] = {icon = "👑 OWNER"},
    ['dev'] = {icon = "💻 DEVELOPER"},
    ['headdev'] = {icon = "🧠 HEAD DEV"},
    ['afk'] = {icon = "💤 AFK"},
}

local function getRainbowColor(offset)
    local r = math.floor(math.sin(offset) * 127 + 128)
    local g = math.floor(math.sin(offset + 2) * 127 + 128)
    local b = math.floor(math.sin(offset + 4) * 127 + 128)
    return r, g, b
end

RegisterNetEvent("displayTag")
AddEventHandler("displayTag", function(role)
    local playerPed = PlayerPedId()
    displayedTag = role
    local timeOffset = 0  

    -- Přehrání zvuku při aktivaci
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    Citizen.CreateThread(function()
        while displayedTag do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(playerPed)
            local cameraCoords = GetGameplayCamCoord()
            local dist = #(cameraCoords - playerCoords)

            if dist < 25.0 then  
                if RoleStyles[role] then
                    local style = RoleStyles[role]
                    local scale = 0.5 + math.sin(timeOffset * 2) * 0.05  
                    local r, g, b = getRainbowColor(timeOffset * 2)  

                    -- Dynamické otáčení textu podle kamery
                    local camRot = GetGameplayCamRot(2)
                    local textRotX = camRot.x
                    local textRotY = camRot.y
                    local textRotZ = camRot.z

                    -- Speciální animace pro OWNERA (točící se korunka)
                    local animatedText = (role == "god") and "🌟👑 OWNER 👑🌟" or (style.icon .. " - " .. playerName)

                    DrawText3D(
                        playerCoords.x, playerCoords.y, playerCoords.z + 1.2 + math.sin(timeOffset) * 0.05,
                        animatedText,
                        r, g, b,
                        scale,
                        textRotX, textRotY, textRotZ
                    )
                end
            end

            timeOffset = timeOffset + 0.05
            if timeOffset > math.pi * 2 then
                timeOffset = 0
            end
        end
    end)
end)

RegisterNetEvent("hideTag")
AddEventHandler("hideTag", function()
    displayedTag = nil
    PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

function DrawText3D(x, y, z, text, r, g, b, scale, rotX, rotY, rotZ)
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(r, g, b, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Detekce neaktivity (AFK systém)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        if GetGameTimer() - lastActionTime > 60000 then 
            if not isAFK then
                isAFK = true
                TriggerServerEvent("setAFKTag")
            end
        else
            if isAFK then
                isAFK = false
                TriggerServerEvent("removeAFKTag")
            end
        end
    end
end)

-- Reset AFK časovače při stisknutí klávesy
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 32) or IsControlJustPressed(0, 33) or IsControlJustPressed(0, 34) or IsControlJustPressed(0, 35) then 
            lastActionTime = GetGameTimer()
        end
    end
end)
