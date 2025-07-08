-- RMF Phone Client Script
local RMFPhone = {}

-- Phone state
local phoneVisible = false
local playerData = {}
local phoneNumber = nil
local contacts = {}
local messages = {}
local callInProgress = false

-- Initialize the phone
CreateThread(function()
    while true do
        if GetResourceState('rmf-core') == 'started' then
            -- Get player data from rmf-core
            TriggerEvent('rmf-core:getPlayerData', function(data)
                playerData = data
                phoneNumber = data.phoneNumber or GeneratePhoneNumber()
            end)
            break
        end
        Wait(1000)
    end
end)

-- Generate a random phone number if none exists
function GeneratePhoneNumber()
    local prefix = "555"
    local number = ""
    for i = 1, 4 do
        number = number .. math.random(0, 9)
    end
    return prefix .. "-" .. number
end

-- Phone toggle function
function RMFPhone.Toggle()
    phoneVisible = not phoneVisible
    
    if phoneVisible then
        RMFPhone.Show()
    else
        RMFPhone.Hide()
    end
end

-- Show phone
function RMFPhone.Show()
    if phoneVisible then return end
    
    phoneVisible = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = "rmf-phone:show",
        data = {
            playerData = playerData,
            phoneNumber = phoneNumber,
            contacts = contacts,
            messages = messages
        }
    })
    
    -- Update status information
    RMFPhone.UpdateBattery()
    RMFPhone.UpdateSignal()
end

-- Hide phone
function RMFPhone.Hide()
    if not phoneVisible then return end
    
    phoneVisible = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = "rmf-phone:hide"
    })
end

-- Update battery level
function RMFPhone.UpdateBattery()
    local battery = math.random(20, 100) -- Simulate battery level
    SendNUIMessage({
        type = "rmf-phone:updateBattery",
        data = { percentage = battery }
    })
end

-- Update signal strength
function RMFPhone.UpdateSignal()
    local signal = math.random(1, 4) -- Simulate signal strength
    SendNUIMessage({
        type = "rmf-phone:updateSignal",
        data = { strength = signal }
    })
end

-- Send notification to phone
function RMFPhone.SendNotification(notification)
    SendNUIMessage({
        type = "rmf-phone:addNotification",
        data = notification
    })
end

-- Receive incoming call
function RMFPhone.ReceiveCall(callerNumber, callerName)
    SendNUIMessage({
        type = "rmf-phone:receiveCall",
        data = {
            number = callerNumber,
            name = callerName or "Unknown"
        }
    })
    
    -- Play ringtone
    PlaySoundFrontend(-1, "Phone_SoundSet_Default", "GTAO_FM_Events_Soundset", true)
end

-- Receive message
function RMFPhone.ReceiveMessage(sender, message, chatId)
    local messageData = {
        sender = sender,
        message = message,
        chatId = chatId,
        timestamp = os.time()
    }
    
    -- Store message
    if not messages[chatId] then
        messages[chatId] = {}
    end
    table.insert(messages[chatId], messageData)
    
    -- Send to UI
    SendNUIMessage({
        type = "rmf-phone:receiveMessage",
        data = messageData
    })
end

-- NUI Callbacks
RegisterNUICallback('rmf-phone:close', function(data, cb)
    RMFPhone.Hide()
    cb('ok')
end)

RegisterNUICallback('rmf-phone:setupComplete', function(data, cb)
    -- Save setup completion to rmf-core
    TriggerServerEvent('rmf-phone:setupComplete', playerData.source)
    cb('ok')
end)

RegisterNUICallback('rmf-phone:appOpened', function(data, cb)
    local app = data.app
    
    -- Log app usage or handle specific app logic
    if app == 'phone' then
        -- Load contacts when phone app opens
        TriggerServerEvent('rmf-phone:getContacts')
    elseif app == 'messages' then
        -- Load messages when messages app opens
        TriggerServerEvent('rmf-phone:getMessages')
    end
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:makeCall', function(data, cb)
    local number = data.number
    
    if not number or number == "" then
        cb('error')
        return
    end
    
    -- Start call
    TriggerServerEvent('rmf-phone:makeCall', number)
    callInProgress = true
    
    -- Simulate call duration
    CreateThread(function()
        Wait(5000) -- 5 second call
        callInProgress = false
        
        -- Send call end notification
        RMFPhone.SendNotification({
            icon = "📞",
            title = "Call Ended",
            text = "Call to " .. number .. " ended",
            time = "now"
        })
    end)
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:sendMessage', function(data, cb)
    local chatId = data.chat
    local message = data.message
    
    if not message or message == "" then
        cb('error')
        return
    end
    
    -- Send message to server
    TriggerServerEvent('rmf-phone:sendMessage', chatId, message)
    
    -- Store message locally
    if not messages[chatId] then
        messages[chatId] = {}
    end
    
    table.insert(messages[chatId], {
        sender = playerData.name or "You",
        message = message,
        sent = true,
        timestamp = os.time()
    })
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:search', function(data, cb)
    local query = data.query
    
    -- Handle search - could integrate with server for real results
    print("Phone search query: " .. query)
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:capturePhoto', function(data, cb)
    -- Handle photo capture
    TriggerServerEvent('rmf-phone:capturePhoto')
    
    -- Could integrate with screenshot functionality
    RMFPhone.SendNotification({
        icon = "📷",
        title = "Photo Captured",
        text = "Photo saved to gallery",
        time = "now"
    })
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:toggleControl', function(data, cb)
    local control = data.control
    
    -- Handle control center toggles
    if control == 'airplane' then
        -- Toggle airplane mode
        print("Airplane mode toggled")
    elseif control == 'wifi' then
        -- Toggle WiFi
        print("WiFi toggled")
    elseif control == 'bluetooth' then
        -- Toggle Bluetooth
        print("Bluetooth toggled")
    elseif control == 'dnd' then
        -- Toggle Do Not Disturb
        print("Do Not Disturb toggled")
    end
    
    cb('ok')
end)

RegisterNUICallback('rmf-phone:setBrightness', function(data, cb)
    local brightness = data.value
    
    -- Handle brightness setting
    print("Brightness set to: " .. brightness .. "%")
    
    cb('ok')
end)

-- Server Events
RegisterNetEvent('rmf-phone:toggle', function()
    RMFPhone.Toggle()
end)

RegisterNetEvent('rmf-phone:show', function()
    RMFPhone.Show()
end)

RegisterNetEvent('rmf-phone:hide', function()
    RMFPhone.Hide()
end)

RegisterNetEvent('rmf-phone:receiveCall', function(callerNumber, callerName)
    RMFPhone.ReceiveCall(callerNumber, callerName)
end)

RegisterNetEvent('rmf-phone:receiveMessage', function(sender, message, chatId)
    RMFPhone.ReceiveMessage(sender, message, chatId)
end)

RegisterNetEvent('rmf-phone:sendNotification', function(notification)
    RMFPhone.SendNotification(notification)
end)

RegisterNetEvent('rmf-phone:updateContacts', function(contactsData)
    contacts = contactsData
end)

RegisterNetEvent('rmf-phone:updateMessages', function(messagesData)
    messages = messagesData
end)

-- RMF Core Events
RegisterNetEvent('rmf-core:playerLoaded', function(data)
    playerData = data
    phoneNumber = data.phoneNumber or GeneratePhoneNumber()
    
    -- Save phone number back to core if it was generated
    if not data.phoneNumber then
        TriggerServerEvent('rmf-phone:savePhoneNumber', phoneNumber)
    end
end)

RegisterNetEvent('rmf-core:playerLogout', function()
    if phoneVisible then
        RMFPhone.Hide()
    end
    
    playerData = {}
    phoneNumber = nil
    contacts = {}
    messages = {}
end)

-- Commands
RegisterCommand('phone', function()
    RMFPhone.Toggle()
end, false)

RegisterCommand('phonecall', function(source, args)
    if args[1] then
        TriggerServerEvent('rmf-phone:makeCall', args[1])
    end
end, false)

RegisterCommand('phonemsg', function(source, args)
    if args[1] and args[2] then
        local chatId = args[1]
        local message = table.concat(args, " ", 2)
        TriggerServerEvent('rmf-phone:sendMessage', chatId, message)
    end
end, false)

-- Key mappings
RegisterKeyMapping('phone', 'Toggle Phone', 'keyboard', 'F1')

-- Export functions for other resources
exports('togglePhone', RMFPhone.Toggle)
exports('showPhone', RMFPhone.Show)
exports('hidePhone', RMFPhone.Hide)
exports('sendNotification', RMFPhone.SendNotification)
exports('receiveCall', RMFPhone.ReceiveCall)
exports('receiveMessage', RMFPhone.ReceiveMessage)

-- Update status periodically
CreateThread(function()
    while true do
        if phoneVisible then
            RMFPhone.UpdateBattery()
            RMFPhone.UpdateSignal()
        end
        Wait(30000) -- Update every 30 seconds
    end
end)