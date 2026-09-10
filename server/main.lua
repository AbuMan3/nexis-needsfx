local QBCore = exports['qb-core']:GetCoreObject()
local soundCooldowns = {}

local EVENTS = {
    requestSound = 'nexis-needsfx:server:requestSpatialSound',
    playSound = 'nexis-needsfx:client:playSpatialSound',
    setHunger = 'nexis-needsfx:server:setHunger'
}

local allowedSounds = {
    [Config.Needs.Hunger.Sound] = true
}

local function setHunger(sourceId, amount)
    local value = tonumber(amount)
    if not value then return end

    local player = QBCore.Functions.GetPlayer(sourceId)
    if not player then return end

    player.Functions.SetMetaData('hunger', math.max(0, math.min(100, value)))
end

RegisterNetEvent(EVENTS.requestSound, function(soundName)
    local src = source
    if not allowedSounds[soundName] then return end

    local now = GetGameTimer()
    local lastPlayed = soundCooldowns[src] or 0

    if now - lastPlayed < Config.Audio.ServerCooldown then
        return
    end

    soundCooldowns[src] = now
    TriggerClientEvent(EVENTS.playSound, -1, src, soundName)
end)

RegisterNetEvent(EVENTS.setHunger, function(amount)
    setHunger(source, amount)
end)

if Config.Compatibility.LegacySetHungerEvent then
    RegisterNetEvent('qb-hunger:server:setHunger', function(amount)
        setHunger(source, amount)
    end)
end

AddEventHandler('playerDropped', function()
    soundCooldowns[source] = nil
end)
