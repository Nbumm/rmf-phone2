-- RMF Phone Server Script
local RMFPhone = {}

-- Server data
local phoneNumbers = {}
local playerContacts = {}
local playerMessages = {}
local activeCalls = {}

-- Database functions (placeholder - integrate with your database system)
local function LoadPlayerPhoneData(playerId)
    -- Load from database
    -- This is a placeholder - replace with your database integration
    local phoneData = {
        phoneNumber = phoneNumbers[playerId],
        contacts = playerContacts[playerId] or {},
        messages = playerMessages[playerId] or {}
    }
    
    return phoneData
end

local function SavePlayerPhoneData(playerId, data)
    -- Save to database
    -- This is a placeholder - replace with your database integration
    if data.phoneNumber then
        phoneNumbers[playerId] = data.phoneNumber
    end
    
    if data.contacts then
        playerContacts[playerId] = data.contacts
    end
    
    if data.messages then
        playerMessages[playerId] = data.messages
    end
end

-- Get player by phone number
local function GetPlayerByPhoneNumber(phoneNumber)
    for playerId, number in pairs(phoneNumbers) do
        if number == phoneNumber then
            return playerId
        end
    end
    return nil
end

-- Generate unique phone number
local function GenerateUniquePhoneNumber()
    local prefix = "555"
    local number
    
    repeat
        number = prefix .. "-"
        for i = 1, 4 do
            number = number .. math.random(0, 9)
        end
    until not GetPlayerByPhoneNumber(number)
    
    return number
end

-- Player Events
RegisterNetEvent('rmf-phone:setupComplete', function(playerId)
    local source = source
    print("Phone setup completed for player: " .. source)
    
    -- Log setup completion or give rewards
    TriggerEvent('rmf-core:logEvent', source, 'phone_setup_complete')
end)

RegisterNetEvent('rmf-phone:savePhoneNumber', function(phoneNumber)
    local source = source
    phoneNumbers[source] = phoneNumber
    
    -- Save to database
    SavePlayerPhoneData(source, { phoneNumber = phoneNumber })
    
    print("Saved phone number " .. phoneNumber .. " for player " .. source)
end)

RegisterNetEvent('rmf-phone:getContacts', function()
    local source = source
    local contacts = playerContacts[source] or {}
    
    TriggerClientEvent('rmf-phone:updateContacts', source, contacts)
end)

RegisterNetEvent('rmf-phone:getMessages', function()
    local source = source
    local messages = playerMessages[source] or {}
    
    TriggerClientEvent('rmf-phone:updateMessages', source, messages)
end)

RegisterNetEvent('rmf-phone:makeCall', function(targetNumber)
    local source = source
    local callerNumber = phoneNumbers[source]
    
    if not callerNumber then
        print("Player " .. source .. " doesn't have a phone number")
        return
    end
    
    local targetPlayer = GetPlayerByPhoneNumber(targetNumber)
    
    if targetPlayer and GetPlayerPing(targetPlayer) > 0 then
        -- Player is online, initiate call
        activeCalls[source] = {
            caller = source,
            target = targetPlayer,
            callerNumber = callerNumber,
            targetNumber = targetNumber,
            startTime = os.time()
        }
        
        -- Notify target player of incoming call
        TriggerClientEvent('rmf-phone:receiveCall', targetPlayer, callerNumber, GetPlayerName(source))
        
        -- Notify caller that call is ringing
        TriggerClientEvent('rmf-phone:sendNotification', source, {
            icon = "📞",
            title = "Calling",
            text = "Calling " .. targetNumber .. "...",
            time = "now"
        })
        
        print("Call initiated from " .. callerNumber .. " to " .. targetNumber)
    else
        -- Player not found or offline
        TriggerClientEvent('rmf-phone:sendNotification', source, {
            icon = "📞",
            title = "Call Failed",
            text = "Number " .. targetNumber .. " is not available",
            time = "now"
        })
    end
end)

RegisterNetEvent('rmf-phone:sendMessage', function(chatId, message)
    local source = source
    local senderNumber = phoneNumbers[source]
    
    if not senderNumber then
        print("Player " .. source .. " doesn't have a phone number")
        return
    end
    
    -- For now, chatId is the target phone number
    local targetNumber = chatId
    local targetPlayer = GetPlayerByPhoneNumber(targetNumber)
    
    local messageData = {
        sender = GetPlayerName(source),
        senderNumber = senderNumber,
        message = message,
        timestamp = os.time(),
        chatId = chatId
    }
    
    -- Store message for sender
    if not playerMessages[source] then
        playerMessages[source] = {}
    end
    if not playerMessages[source][chatId] then
        playerMessages[source][chatId] = {}
    end
    table.insert(playerMessages[source][chatId], messageData)
    
    if targetPlayer and GetPlayerPing(targetPlayer) > 0 then
        -- Store message for recipient
        if not playerMessages[targetPlayer] then
            playerMessages[targetPlayer] = {}
        end
        if not playerMessages[targetPlayer][senderNumber] then
            playerMessages[targetPlayer][senderNumber] = {}
        end
        table.insert(playerMessages[targetPlayer][senderNumber], messageData)
        
        -- Send message to target player
        TriggerClientEvent('rmf-phone:receiveMessage', targetPlayer, GetPlayerName(source), message, senderNumber)
        
        print("Message sent from " .. senderNumber .. " to " .. targetNumber .. ": " .. message)
    else
        -- Store as offline message
        print("Message stored for offline player: " .. targetNumber)
    end
    
    -- Save to database
    SavePlayerPhoneData(source, { messages = playerMessages[source] })
    if targetPlayer then
        SavePlayerPhoneData(targetPlayer, { messages = playerMessages[targetPlayer] })
    end
end)

RegisterNetEvent('rmf-phone:capturePhoto', function()
    local source = source
    
    -- Handle photo capture logic
    print("Player " .. source .. " captured a photo")
    
    -- Could save screenshot data or generate photo items
    TriggerEvent('rmf-core:giveItem', source, 'photo', 1)
end)

-- RMF Core Integration
RegisterNetEvent('rmf-core:playerLoaded', function(playerId, playerData)
    -- Load phone data when player connects
    local phoneData = LoadPlayerPhoneData(playerId)
    
    if not phoneData.phoneNumber then
        -- Generate new phone number if player doesn't have one
        phoneData.phoneNumber = GenerateUniquePhoneNumber()
        phoneNumbers[playerId] = phoneData.phoneNumber
        SavePlayerPhoneData(playerId, phoneData)
    else
        phoneNumbers[playerId] = phoneData.phoneNumber
    end
    
    playerContacts[playerId] = phoneData.contacts or {}
    playerMessages[playerId] = phoneData.messages or {}
    
    print("Phone data loaded for player " .. playerId .. " with number " .. phoneData.phoneNumber)
end)

RegisterNetEvent('rmf-core:playerDropped', function(playerId)
    -- Clean up player data
    if activeCalls[playerId] then
        local call = activeCalls[playerId]
        if call.target and call.target ~= playerId then
            TriggerClientEvent('rmf-phone:sendNotification', call.target, {
                icon = "📞",
                title = "Call Ended",
                text = "Call ended - caller disconnected",
                time = "now"
            })
        end
        activeCalls[playerId] = nil
    end
    
    -- Save final data before cleanup
    SavePlayerPhoneData(playerId, {
        phoneNumber = phoneNumbers[playerId],
        contacts = playerContacts[playerId],
        messages = playerMessages[playerId]
    })
    
    phoneNumbers[playerId] = nil
    playerContacts[playerId] = nil
    playerMessages[playerId] = nil
    
    print("Phone data cleaned up for player " .. playerId)
end)

-- Admin Commands
RegisterCommand('givephone', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'admin') then
        local targetId = tonumber(args[1])
        if targetId and GetPlayerPing(targetId) > 0 then
            local phoneNumber = GenerateUniquePhoneNumber()
            phoneNumbers[targetId] = phoneNumber
            
            TriggerClientEvent('rmf-phone:sendNotification', targetId, {
                icon = "📱",
                title = "New Phone",
                text = "You received a new phone with number " .. phoneNumber,
                time = "now"
            })
            
            print("Gave phone number " .. phoneNumber .. " to player " .. targetId)
        end
    end
end, true)

RegisterCommand('callplayer', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'admin') then
        local callerId = tonumber(args[1])
        local targetId = tonumber(args[2])
        
        if callerId and targetId and GetPlayerPing(callerId) > 0 and GetPlayerPing(targetId) > 0 then
            local callerNumber = phoneNumbers[callerId] or "Admin"
            TriggerClientEvent('rmf-phone:receiveCall', targetId, callerNumber, GetPlayerName(callerId))
            print("Admin initiated call from " .. callerId .. " to " .. targetId)
        end
    end
end, true)

RegisterCommand('sendmsg', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'admin') then
        local targetId = tonumber(args[1])
        if targetId and GetPlayerPing(targetId) > 0 and args[2] then
            local message = table.concat(args, " ", 2)
            TriggerClientEvent('rmf-phone:receiveMessage', targetId, "System", message, "system")
            print("Admin sent message to " .. targetId .. ": " .. message)
        end
    end
end, true)

-- API Functions for other resources
function RMFPhone.GetPlayerPhoneNumber(playerId)
    return phoneNumbers[playerId]
end

function RMFPhone.SetPlayerPhoneNumber(playerId, phoneNumber)
    phoneNumbers[playerId] = phoneNumber
    SavePlayerPhoneData(playerId, { phoneNumber = phoneNumber })
end

function RMFPhone.SendMessage(targetPlayerId, sender, message)
    if GetPlayerPing(targetPlayerId) > 0 then
        TriggerClientEvent('rmf-phone:receiveMessage', targetPlayerId, sender, message, "system")
        return true
    end
    return false
end

function RMFPhone.SendNotification(targetPlayerId, notification)
    if GetPlayerPing(targetPlayerId) > 0 then
        TriggerClientEvent('rmf-phone:sendNotification', targetPlayerId, notification)
        return true
    end
    return false
end

function RMFPhone.CallPlayer(callerId, targetId)
    local callerNumber = phoneNumbers[callerId]
    local targetNumber = phoneNumbers[targetId]
    
    if callerNumber and targetNumber and GetPlayerPing(callerId) > 0 and GetPlayerPing(targetId) > 0 then
        TriggerClientEvent('rmf-phone:receiveCall', targetId, callerNumber, GetPlayerName(callerId))
        return true
    end
    return false
end

-- Exports for other resources
exports('getPlayerPhoneNumber', RMFPhone.GetPlayerPhoneNumber)
exports('setPlayerPhoneNumber', RMFPhone.SetPlayerPhoneNumber)
exports('sendMessage', RMFPhone.SendMessage)
exports('sendNotification', RMFPhone.SendNotification)
exports('callPlayer', RMFPhone.CallPlayer)

-- Cleanup active calls periodically
CreateThread(function()
    while true do
        local currentTime = os.time()
        
        for callerId, callData in pairs(activeCalls) do
            -- End calls after 60 seconds
            if currentTime - callData.startTime > 60 then
                TriggerClientEvent('rmf-phone:sendNotification', callerId, {
                    icon = "📞",
                    title = "Call Ended",
                    text = "Call ended - timeout",
                    time = "now"
                })
                
                if callData.target and GetPlayerPing(callData.target) > 0 then
                    TriggerClientEvent('rmf-phone:sendNotification', callData.target, {
                        icon = "📞",
                        title = "Call Ended",
                        text = "Call ended - timeout",
                        time = "now"
                    })
                end
                
                activeCalls[callerId] = nil
            end
        end
        
        Wait(5000) -- Check every 5 seconds
    end
end)

print("RMF Phone server script loaded successfully")