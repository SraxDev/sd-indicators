RegisterServerEvent('sd-indicators:syncIndicator')
AddEventHandler('sd-indicators:syncIndicator', function(indicator)
    local playerid = source
    TriggerClientEvent('sd-indicators:syncIndicator', -1, playerid, indicator)
end)
