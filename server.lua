ESX = nil
local cokeEntrance = math.random(1, #Config.CokeEntrances)
local methEntrance = math.random(1, #Config.MethEntrances)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('krp_druglabs:getEntrances')
AddEventHandler('krp_druglabs:getEntrances', function()
    TriggerClientEvent('krp_druglabs:setEntrances', source, cokeEntrance, methEntrance)
end)

RegisterServerEvent('krp_druglabs:buySupplies')
AddEventHandler('krp_druglabs:buySupplies', function(type)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local price = 0
    local suppliesAmount = xPlayer.getInventoryItem(type .. '_supplies').count
    local suppliesLimit = xPlayer.getInventoryItem(type .. '_supplies').limit

    if type == 'meth' then
        price = Config.MethSupplyPrice
    else
        price = Config.CokeSupplyPrice
    end

    if suppliesAmount < suppliesLimit then
        if xPlayer.getMoney() >= price then
            -- give supply to player
            xPlayer.removeMoney(price)
            xPlayer.addInventoryItem(type .. '_supplies', 1)
            TriggerClientEvent('esx:showNotification', _source, 'You have purchased ' .. type .. ' supplies')
        else
            -- sorry, not enough money
            local missingMoney = price - xPlayer.getMoney()
            TriggerClientEvent('esx:showNotification', _source, 'You need $' .. missingMoney .. ' more in order to afford supplies')
        end
    else
        TriggerClientEvent('esx:showNotification', _source, 'You cannot hold any more ' .. type .. ' supplies')
    end
end)

RegisterServerEvent('krp_druglabs:checkSupplies')
AddEventHandler('krp_druglabs:checkSupplies', function(type)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local suppliesAmount = xPlayer.getInventoryItem(type .. '_supplies').count

    if type == 'coke' then
        -- coke also needs plants even if we have supplies
        local plantAmount = xPlayer.getInventoryItem(type .. '_plant').count

        if (suppliesAmount > 0 and plantAmount >= Config.CokePlantsUsed) then
            xPlayer.removeInventoryItem(type .. '_plant', Config.CokePlantsUsed)
            TriggerClientEvent('krp_druglabs:startProcessing', _source, type)
        elseif plantAmount >= Config.CokePlantsUsed then
            TriggerClientEvent('esx:showNotification', _source, 'You need ' .. type .. ' supplies in order to proceed')
        elseif suppliesAmount > 0 then
            TriggerClientEvent('esx:showNotification', _source, 'You need at least ' .. Config.CokePlantsUsed .. ' ' .. type .. ' plants in order to proceed')
        else
            TriggerClientEvent('esx:showNotification', _source, 'You need ' .. type .. ' supplies and at least ' .. Config.CokePlantsUsed .. ' ' .. type .. ' plants in order to proceed')
        end
    else
        if suppliesAmount > 0 then
            TriggerClientEvent('krp_druglabs:startProcessing', _source, type)
        else
            TriggerClientEvent('esx:showNotification', _source, 'You need ' .. type .. ' supplies in order to proceed')
        end
    end
end)

RegisterServerEvent('krp_druglabs:harvestCoke')
AddEventHandler('krp_druglabs:harvestCoke', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local configAmount = Config.CokeFieldAmount
    local plantAmount = xPlayer.getInventoryItem('coke_plant').count
    local plantLimit = xPlayer.getInventoryItem('coke_plant').limit

    local harvestedAmount = math.random(configAmount.min, configAmount.max)

    if plantAmount + harvestedAmount <= plantLimit then
        xPlayer.addInventoryItem('coke_plant', harvestedAmount)
        TriggerClientEvent('esx:showNotification', _source, 'You have harvested ' .. harvestedAmount .. ' coke plants')
    elseif plantLimit - plantAmount > 0 then
        local amt = plantLimit - plantAmount
        xPlayer.addInventoryItem('coke_plant', amt)
        TriggerClientEvent('esx:showNotification', _source, 'You have harvested ' .. amt .. ' coke plants')
    else
        TriggerClientEvent('esx:showNotification', _source, 'You cannot hold the harvested plant')
    end
end)

RegisterServerEvent('krp_druglabs:getDrug')
AddEventHandler('krp_druglabs:getDrug', function(type)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local configAmount = {}
    local suppliesAmount = xPlayer.getInventoryItem(type .. '_supplies').count
    local drugLimit = xPlayer.getInventoryItem(type).limit
    local drugOwned = xPlayer.getInventoryItem(type).count

    if suppliesAmount > 0 then
        if type == 'meth' then
            configAmount = Config.MethAmount
        else
            configAmount = Config.CokeAmount
        end
        local drugAmount = math.random(configAmount.min, configAmount.max)

        if drugOwned + drugAmount <= drugLimit then
            xPlayer.addInventoryItem(type, drugAmount)
            xPlayer.removeInventoryItem(type .. '_supplies', 1)
            TriggerClientEvent('esx:showNotification', _source, 'You have produced ' .. drugAmount .. ' grams of ' .. type)
        elseif drugLimit - drugOwned > 0 then
            local amt = drugLimit - drugOwned
            xPlayer.addInventoryItem(type, amt)
            xPlayer.removeInventoryItem(type .. '_supplies', 1)
            TriggerClientEvent('esx:showNotification', _source, 'You have produced ' .. amt .. ' grams of ' .. type)
        else
            TriggerClientEvent('esx:showNotification', _source, 'You cannot hold the produced ' .. type)
        end
    else
        TriggerClientEvent('esx:showNotification', _source, 'You need ' .. type .. ' supplies in order to proceed')
    end
end)