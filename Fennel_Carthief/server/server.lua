ESX = exports.es_extended:getSharedObject()

RegisterServerEvent('controllo:item', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(Config.Lockpickname).count

    if item > Config.Lockpickremove or item == Config.Lockpickremove then
        xPlayer.removeInventoryItem(Config.Lockpickname, Config.Lockpickremove)
        TriggerClientEvent('skill:opencar', source)
    else
        TriggerClientEvent('esx:showNotification', source, "Non Hai Un Grimaldello!")
    end
end)

RegisterServerEvent('pagamento:cash', function(money)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem("money", money)
end)