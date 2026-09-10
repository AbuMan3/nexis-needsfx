Config = {}

Config.Needs = {
    Hunger = {
        Enabled = true,
        Threshold = 20,
        Cooldown = 30000,
        Sound = 'hungry'
    },
    Thirst = {
        Enabled = true,
        Threshold = 20,
        Cooldown = 25000,
        Message = 'تراك عطشان كل شوي لازم تشرب',
        NotifyType = 'error',
        NotifyDuration = 4000
    }
}

Config.Audio = {
    Radius = 10.0,
    FullVolumeDistance = 1.25,
    Volume = 0.34,
    Falloff = 1.65,
    UpdateInterval = 75,
    MaxPlaybackTime = 6000,
    ServerCooldown = 20000
}

Config.Compatibility = {
    LegacySetHungerEvent = true
}
