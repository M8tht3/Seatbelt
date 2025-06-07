SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
local seatbeltOn = false
local ped = nil
local uiactive = false

Citizen.CreateThread(function()
    while true do
        ped = PlayerPedId()
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsPedInAnyVehicle(ped) then
            if seatbeltOn then
                if Config.fixedWhileBuckled then
                    DisableControlAction(0, 75, true)
                    DisableControlAction(27, 75, true)
                end
                toggleUI(false)
            else
                toggleUI(true)
            end

            if IsControlJustReleased(0, 311) then 
                ExecuteCommand("toggleseatbelt")
            end
        else
            if seatbeltOn then
                seatbeltOn = false
                toggleSeatbelt(false, false)
            end
            toggleUI(false)
            Citizen.Wait(1000)
        end
    end
end)

function toggleSeatbelt(makeSound, toggle)
    if toggle == nil then
        if seatbeltOn then
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)

            lib.notify({
                id = 'seatbelt_off',
                title = 'Seatbelt',
                description = 'You have taken off your seatbelt.',
                duration = 4000,
                position = 'top',
                style = {
                    backgroundColor = 'rgba(18, 18, 18, 0.95)',
                    borderRadius = '10px',
                    padding = '12px 18px',
                    color = '#ffffff',
                    fontWeight = 'bold',
                    boxShadow = '0 4px 12px rgba(0, 0, 0, 0.6)',
                    ['.description'] = {
                        color = '#c0c0c0',
                        fontWeight = 'normal'
                    }
                },
                icon = 'x',
                iconColor = '#ef4444'
            })
        else
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0)

            lib.notify({
                id = 'seatbelt_on',
                title = 'Seatbelt',
                description = 'You have put on your seatbelt.',
                duration = 4000,
                position = 'top',
                style = {
                    backgroundColor = 'rgba(18, 18, 18, 0.95)',
                    borderRadius = '10px',
                    padding = '12px 18px',
                    color = '#ffffff',
                    fontWeight = 'bold',
                    boxShadow = '0 4px 12px rgba(0, 0, 0, 0.6)',
                    ['.description'] = {
                        color = '#c0c0c0',
                        fontWeight = 'normal'
                    }
                },
                icon = 'check',
                iconColor = '#22c55e'
            })
        end
        seatbeltOn = not seatbeltOn
    else
        if toggle then
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0)

            lib.notify({
                id = 'seatbelt_on',
                title = 'Seatbelt',
                description = 'You have put on your seatbelt.',
                duration = 4000,
                position = 'top',
                style = {
                    backgroundColor = 'rgba(18, 18, 18, 0.95)',
                    borderRadius = '10px',
                    padding = '12px 18px',
                    color = '#ffffff',
                    fontWeight = 'bold',
                    boxShadow = '0 4px 12px rgba(0, 0, 0, 0.6)',
                    ['.description'] = {
                        color = '#c0c0c0',
                        fontWeight = 'normal'
                    }
                },
                icon = 'check',
                iconColor = '#22c55e'
            })
        else
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)

            lib.notify({
                id = 'seatbelt_off',
                title = 'Seatbelt',
                description = 'You have taken off your seatbelt.',
                duration = 4000,
                position = 'top',
                style = {
                    backgroundColor = 'rgba(18, 18, 18, 0.95)',
                    borderRadius = '10px',
                    padding = '12px 18px',
                    color = '#ffffff',
                    fontWeight = 'bold',
                    boxShadow = '0 4px 12px rgba(0, 0, 0, 0.6)',
                    ['.description'] = {
                        color = '#c0c0c0',
                        fontWeight = 'normal'
                    }
                },
                icon = 'x',
                iconColor = '#ef4444'
            })
        end
        seatbeltOn = toggle
    end
end

function toggleUI(status)
    if Config.showUnbuckledIndicator then
        if uiactive ~= status then
            uiactive = status
            if status then
                SendNUIMessage({type = "showindicator"})
            else
                SendNUIMessage({type = "hideindicator"})
            end
        end
    end
end

function playSound(action)
    if Config.playSound then
        if Config.playSoundForPassengers then
            local veh = GetVehiclePedIsUsing(ped)
            local maxpeds = GetVehicleMaxNumberOfPassengers(veh) - 2
            local passengers = {}
            for i = -1, maxpeds do
                if not IsVehicleSeatFree(veh, i) then
                    local targetPed = GetPedInVehicleSeat(veh, i)
                    local targetPlayer = NetworkGetPlayerIndexFromPed(targetPed)
                    if targetPlayer ~= -1 then
                        table.insert(passengers, GetPlayerServerId(targetPlayer))
                    end
                end
            end
            TriggerServerEvent('seatbelt:server:PlaySound', action, json.encode(passengers))
        else
            SendNUIMessage({type = action, volume = Config.volume})
        end
    end
end

RegisterCommand('toggleseatbelt', function()
    if IsPedInAnyVehicle(ped, false) then
        local class = GetVehicleClass(GetVehiclePedIsIn(ped))
        if class ~= 8 and class ~= 13 and class ~= 14 then
            toggleSeatbelt(true)
        end
    end
end)

RegisterNetEvent('seatbelt:client:PlaySound', function(action, volume)
    SendNUIMessage({type = action, volume = volume})
end)

exports("status", function()
    return seatbeltOn
end)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'K')
