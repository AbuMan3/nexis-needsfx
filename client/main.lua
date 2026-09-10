local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local lastHungerWarning = 0
local lastThirstWarning = 0
local activeSpatial = {}
local spatialThreadRunning = false

local EVENTS = {
    requestSound = 'nexis-needsfx:server:requestSpatialSound',
    playSound = 'nexis-needsfx:client:playSpatialSound'
}

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function getVolume(distance)
    local radius = Config.Audio.Radius
    local fullDistance = Config.Audio.FullVolumeDistance

    if distance >= radius then
        return 0.0
    end

    if distance <= fullDistance then
        return Config.Audio.Volume
    end

    local progress = (distance - fullDistance) / math.max(radius - fullDistance, 0.001)
    local curve = math.pow(1.0 - clamp(progress, 0.0, 1.0), Config.Audio.Falloff)
    return Config.Audio.Volume * curve
end

local function getSpatialData(sourcePed)
    local listenerPed = PlayerPedId()
    local listenerCoords = GetEntityCoords(listenerPed)
    local sourceCoords = GetEntityCoords(sourcePed)
    local delta = sourceCoords - listenerCoords
    local distance = #(delta)

    if distance > Config.Audio.Radius then
        return nil
    end

    local rotation = GetGameplayCamRot(2)
    local yaw = math.rad(rotation.z)
    local pitch = math.rad(rotation.x)
    local pitchScale = math.abs(math.cos(pitch))

    local forwardX = -math.sin(yaw) * pitchScale
    local forwardY = math.cos(yaw) * pitchScale
    local forwardZ = math.sin(pitch)
    local rightX = math.cos(yaw)
    local rightY = math.sin(yaw)

    local x = (delta.x * rightX) + (delta.y * rightY)
    local y = (delta.x * forwardX) + (delta.y * forwardY) + (delta.z * forwardZ)
    local z = delta.z

    return {
        x = x,
        y = y,
        z = z,
        volume = getVolume(distance)
    }
end

local function stopSpatial(id)
    if not activeSpatial[id] then return end
    activeSpatial[id] = nil
    SendNUIMessage({
        action = 'stopSpatial',
        id = id
    })
end

local function startSpatialThread()
    if spatialThreadRunning then return end
    spatialThreadRunning = true

    CreateThread(function()
        while next(activeSpatial) do
            local now = GetGameTimer()

            for id, playback in pairs(activeSpatial) do
                local player = GetPlayerFromServerId(playback.serverId)

                if player == -1 or now - playback.startedAt > Config.Audio.MaxPlaybackTime then
                    stopSpatial(id)
                else
                    local ped = GetPlayerPed(player)

                    if ped == 0 or not DoesEntityExist(ped) then
                        stopSpatial(id)
                    else
                        local spatial = getSpatialData(ped)

                        if spatial then
                            SendNUIMessage({
                                action = 'updateSpatial',
                                id = id,
                                x = spatial.x,
                                y = spatial.y,
                                z = spatial.z,
                                volume = spatial.volume
                            })
                        else
                            SendNUIMessage({
                                action = 'updateSpatial',
                                id = id,
                                x = 0.0,
                                y = 1.0,
                                z = 0.0,
                                volume = 0.0
                            })
                        end
                    end
                end
            end

            Wait(Config.Audio.UpdateInterval)
        end

        spatialThreadRunning = false
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}

    for id in pairs(activeSpatial) do
        stopSpatial(id)
    end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(value)
    PlayerData = value
end)

RegisterNetEvent(EVENTS.playSound, function(serverId, soundName)
    local player = GetPlayerFromServerId(serverId)
    if player == -1 then return end

    local ped = GetPlayerPed(player)
    if ped == 0 or not DoesEntityExist(ped) then return end

    local spatial = getSpatialData(ped)
    if not spatial or spatial.volume <= 0.0 then return end

    local id = ('%s:%s:%s:%s'):format(serverId, soundName, GetGameTimer(), math.random(10000, 99999))
    activeSpatial[id] = {
        serverId = serverId,
        startedAt = GetGameTimer()
    }

    SendNUIMessage({
        action = 'playSpatial',
        id = id,
        file = soundName,
        x = spatial.x,
        y = spatial.y,
        z = spatial.z,
        volume = spatial.volume
    })

    startSpatialThread()
end)

RegisterNUICallback('audioEnded', function(data, cb)
    if data and data.id then
        activeSpatial[data.id] = nil
    end

    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(5000)

        if PlayerData and PlayerData.metadata then
            local hunger = PlayerData.metadata.hunger or 100
            local thirst = PlayerData.metadata.thirst or 100
            local now = GetGameTimer()

            if Config.Needs.Hunger.Enabled and hunger <= Config.Needs.Hunger.Threshold and now - lastHungerWarning > Config.Needs.Hunger.Cooldown then
                TriggerServerEvent(EVENTS.requestSound, Config.Needs.Hunger.Sound)
                lastHungerWarning = now
            end

            if Config.Needs.Thirst.Enabled and thirst <= Config.Needs.Thirst.Threshold and now - lastThirstWarning > Config.Needs.Thirst.Cooldown then
                QBCore.Functions.Notify(
                    Config.Needs.Thirst.Message,
                    Config.Needs.Thirst.NotifyType,
                    Config.Needs.Thirst.NotifyDuration
                )
                lastThirstWarning = now
            end
        end
    end
end)
