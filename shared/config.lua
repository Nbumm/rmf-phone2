-- RMF Phone Shared Configuration
Config = {}

-- Phone Settings
Config.PhoneKey = 'F1' -- Key to toggle phone
Config.MaxCallDuration = 300 -- Max call duration in seconds (5 minutes)
Config.MaxMessageLength = 500 -- Max characters per message
Config.MaxContacts = 100 -- Max contacts per player

-- Visual Settings
Config.PhonePosition = {
    x = 0.5, -- Center of screen
    y = 0.5
}

Config.PhoneScale = 1.0 -- Scale of the phone UI

-- Battery Settings
Config.BatteryDrain = true -- Enable battery drain simulation
Config.BatteryDrainRate = 1 -- Battery percentage lost per hour
Config.LowBatteryWarning = 20 -- Show warning when battery below this %

-- Signal Settings
Config.SignalSimulation = true -- Enable signal strength simulation
Config.SignalAreas = {
    -- Define areas with different signal strengths (1-4 bars)
    {
        name = "City Center",
        coords = vector3(0, 0, 0),
        radius = 1000,
        signal = 4
    },
    {
        name = "Suburbs",
        coords = vector3(1000, 1000, 0),
        radius = 500,
        signal = 3
    },
    {
        name = "Rural Area",
        coords = vector3(-2000, -2000, 0),
        radius = 800,
        signal = 2
    },
    {
        name = "Mountains",
        coords = vector3(3000, 3000, 500),
        radius = 1200,
        signal = 1
    }
}

-- App Settings
Config.EnabledApps = {
    phone = true,
    messages = true,
    google = true,
    camera = true,
    settings = true
}

-- Sound Settings
Config.Sounds = {
    ringtone = "Phone_SoundSet_Default",
    notification = "Text_Arrive_Tone",
    keypad = "Menu_Accept",
    camera = "Camera_Shoot"
}

-- Phone Number Settings
Config.PhoneNumberFormat = "XXX-XXXX" -- Format for generated numbers
Config.PhoneNumberPrefix = "555" -- Default area code

-- Message Settings
Config.MessageCost = 0 -- Cost per message (0 = free)
Config.CallCost = 0 -- Cost per minute of call (0 = free)

-- Integration Settings
Config.RMFCoreEvents = {
    playerLoaded = "rmf-core:playerLoaded",
    playerDropped = "rmf-core:playerDropped",
    getPlayerData = "rmf-core:getPlayerData",
    logEvent = "rmf-core:logEvent",
    giveItem = "rmf-core:giveItem"
}

-- Database Settings (if using custom database)
Config.Database = {
    enabled = false, -- Set to true if using custom database
    table = "phone_data",
    columns = {
        player_id = "player_id",
        phone_number = "phone_number",
        contacts = "contacts",
        messages = "messages",
        settings = "settings"
    }
}

-- Admin Settings
Config.AdminGroups = {
    "admin",
    "moderator"
}

-- Notification Settings
Config.NotificationDuration = 5000 -- How long notifications show (ms)
Config.MaxNotifications = 10 -- Max notifications to keep

-- Debug Settings
Config.Debug = false -- Enable debug prints
Config.DevMode = false -- Enable development features

-- Custom Apps (for future expansion)
Config.CustomApps = {
    -- Example:
    -- banking = {
    --     name = "Bank",
    --     icon = "💰",
    --     enabled = true,
    --     url = "nui://banking/index.html"
    -- }
}