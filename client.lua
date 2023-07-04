local indicator = "Off"
local pedHeading = 0.0
local indicatorTime = 0

RegisterNetEvent('sd-indicators:syncIndicator')
AddEventHandler('sd-indicators:syncIndicator', function(playerId, IStatus)
    if GetPlayerFromServerId(playerId) ~= PlayerId() then
        local ped = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(playerId)), false)
        if ped then
            if IStatus == "Off" then
                SetVehicleIndicatorLights(ped, 0, false)
                SetVehicleIndicatorLights(ped, 1, false)
            elseif IStatus == "Left" then
                SetVehicleIndicatorLights(ped, 0, false)
                SetVehicleIndicatorLights(ped, 1, true)
            elseif IStatus == "Right" then
                SetVehicleIndicatorLights(ped, 0, true)
                SetVehicleIndicatorLights(ped, 1, false)
            elseif IStatus == "Both" then
                SetVehicleIndicatorLights(ped, 0, true)
                SetVehicleIndicatorLights(ped, 1, true)
            end
        end
    end
end)

AddEventHandler('sd-indicators:setIndicator', function(IStatus)
    local ped = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local HasTrailer, vehTrailer = GetVehicleTrailerVehicle(ped, vehTrailer)
    if ped then
        if IStatus == "Off" then
            SetVehicleIndicatorLights(ped, 0, false)
            SetVehicleIndicatorLights(ped, 1, false)
            if HasTrailer then
                SetVehicleIndicatorLights(vehTrailer, 0, false)
                SetVehicleIndicatorLights(vehTrailer, 1, false)
            end
        elseif IStatus == "Left" then
            SetVehicleIndicatorLights(ped, 0, false)
            SetVehicleIndicatorLights(ped, 1, true)
            if HasTrailer then
                SetVehicleIndicatorLights(vehTrailer, 0, false)
                SetVehicleIndicatorLights(vehTrailer, 1, true)
            end
        elseif IStatus == "Right" then
            SetVehicleIndicatorLights(ped, 0, true)
            SetVehicleIndicatorLights(ped, 1, false)
            if HasTrailer then
                SetVehicleIndicatorLights(vehTrailer, 0, true)
                SetVehicleIndicatorLights(vehTrailer, 1, false)
            end
        elseif IStatus == "Both" then
            SetVehicleIndicatorLights(ped, 0, true)
            SetVehicleIndicatorLights(ped, 1, true)
            if HasTrailer then
                SetVehicleIndicatorLights(vehTrailer, 0, true)
                SetVehicleIndicatorLights(vehTrailer, 1, true)
            end
        end
    end
end)

RegisterNetEvent('sd-indicators:syncHazards')
AddEventHandler('sd-indicators:setHazards', function(hazardsDeactivate)
    local ped = GetVehiclePedIsIn(GetPlayerPed(-1), true)
    if ped then
        local setHazards = not (hazardsDeactivate == "false" or hazardsDeactivate == "0" or hazardsDeactivate == "off")
        indicator = setHazards and "Both" or "Off"
        TriggerServerEvent("sd-indicators:syncIndicator", indicator)
        TriggerEvent("sd-indicators:setIndicator", indicator)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if ped and GetPedInVehicleSeat(ped, -1) == GetPlayerPed(-1) then
            if IsControlJustPressed(1, 174) then
                indicatorTime = 0
                if indicator == "Left" then
                    indicator = "Off"
                else
                    indicator = "Left"
                    pedHeading = GetEntityHeading(ped)
                end
                TriggerServerEvent("sd-indicators:syncIndicator", indicator)
                TriggerEvent("sd-indicators:setIndicator", indicator)
            elseif IsControlJustPressed(1, 175) then
                indicatorTime = 0
                if indicator == "Right" then
                    indicator = "Off"
                else
                    indicator = "Right"
                    pedHeading = GetEntityHeading(ped)
                end
                TriggerServerEvent("sd-indicators:syncIndicator", indicator)
                TriggerEvent("sd-indicators:setIndicator", indicator)
            elseif IsControlJustPressed(1, 173) then
                indicatorTime = 0
                if indicator == "Both" then
                    indicator = "Off"
                else
                    indicator = "Both"
                    pedHeading = GetEntityHeading(ped)
                end
                TriggerServerEvent("sd-indicators:syncIndicator", indicator)
                TriggerEvent("sd-indicators:setIndicator", indicator)
            end
            if indicatorTime == 0 then
                if indicator ~= "Off" then
                    local pedNewHeading = GetEntityHeading(ped)
                    if math.abs(pedNewHeading - pedHeading) > 60.0 then
                        indicatorTime = GetGameTimer() + 1500
                    end
                end
            elseif GetGameTimer() >= indicatorTime and indicator ~= "Both" and (indicator == "Left" or indicator == "Right") then
                indicator = "Off"
                TriggerServerEvent("sd-indicators:syncIndicator", indicator)
                TriggerEvent("sd-indicators:setIndicator", indicator)
            end
        end
        if ped and ped ~= false and GetPedInVehicleSeat(ped, -1) == GetPlayerPed(-1) and IsVehicleEngineOn(ped) then
            if GetEntitySpeed(ped) < 4 and not IsControlPressed(1, 32) then
                SetVehicleBrakeLights(ped, true)
            end
        end
        for playerIds = 0, 31 do
            if NetworkIsPlayerActive(playerIds) then
                local networkPed = GetPlayerPed(GetPlayerFromServerId(playerIds))
                local networkPedVeh = GetVehiclePedIsIn(networkPed, false)
                if networkPedVeh and GetPlayerFromServerId(playerIds) ~= PlayerId() and GetPedInVehicleSeat(networkPedVeh, -1) == networkPed and IsVehicleEngineOn(networkPedVeh) then
                    if GetEntitySpeed(networkPedVeh) < 2 then
                        SetVehicleBrakeLights(networkPedVeh, true)
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)
