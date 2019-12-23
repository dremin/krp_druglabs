ESX = nil
local PlayerData = {}
local isHarvesting = false
local cokeStep = 0
local methStep = 0

local cokeEntrance = 1
local methEntrance = 1

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj)
			ESX = obj
			PlayerData = ESX.GetPlayerData()
		end)
		Citizen.Wait(0)
	end

	TriggerServerEvent('krp_druglabs:getEntrances')
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('krp_druglabs:setEntrances')
AddEventHandler('krp_druglabs:setEntrances', function (coke, meth)
	cokeEntrance = coke
	methEntrance = meth
end)

RegisterNetEvent('krp_druglabs:startProcessing')
AddEventHandler('krp_druglabs:startProcessing', function (type)
	if type == 'meth' then
		methStep = -1
		TriggerEvent('esx:showNotification', 'Please wait while the meth is being mixed')
		runScenario("CODE_HUMAN_MEDIC_KNEEL", 'Mixing meth supplies...', Config.MethMixerTime, function()
			TriggerEvent('esx:showNotification', 'The meth is now mixed')
			methStep = 1
		end)
	else
		cokeStep = -1
		TriggerEvent('esx:showNotification', 'Please wait while the coke is being cut')
		runScenario("CODE_HUMAN_MEDIC_KNEEL", 'Cutting coke...', Config.CokeCuttingTime, function()
			TriggerEvent('esx:showNotification', 'The coke is now cut')
			cokeStep = 1
		end)
	end
end)

-- Draw markers
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		local ped = PlayerPedId()
		local playerCoords = GetEntityCoords(ped, true)

		-- COKE --
		-- coke lab entrance
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeEntrances[cokeEntrance].x, Config.CokeEntrances[cokeEntrance].y, Config.CokeEntrances[cokeEntrance].z, true) <= 3.0 then
			DrawText3D(Config.CokeEntrances[cokeEntrance].x, Config.CokeEntrances[cokeEntrance].y, Config.CokeEntrances[cokeEntrance].z + 1.0, 'Press [E] to enter the coke lab')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				enterCokeLab(ped)
			end
		end

		-- coke lab locked entrances --
		for i=1, #Config.CokeEntrances, 1 do
			if i ~= cokeEntrance then
				if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeEntrances[i].x, Config.CokeEntrances[i].y, Config.CokeEntrances[i].z, true) <= 3.0 then
					DrawText3D(Config.CokeEntrances[i].x, Config.CokeEntrances[i].y, Config.CokeEntrances[i].z + 1.0, 'This coke lab is currently closed')
					sleep = 0
				end
			end
		end
		
		-- coke lab exit
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeExit.x, Config.CokeExit.y, Config.CokeExit.z, true) <= 2.0 then
			DrawText3D(Config.CokeExit.x, Config.CokeExit.y, Config.CokeExit.z + 1.0, 'Press [E] to leave the coke lab')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				exitCokeLab(ped)
			end
		end

		-- coke supply
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeSupply.x, Config.CokeSupply.y, Config.CokeSupply.z, true) <= 1.0 then
			DrawText3D(Config.CokeSupply.x, Config.CokeSupply.y, Config.CokeSupply.z + 1.0, 'Press [E] to purchase black market coke supplies ($' .. Config.CokeSupplyPrice .. ')')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				TriggerServerEvent('krp_druglabs:buySupplies', 'coke')
			end
		end

		-- coke harvest
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeField.x, Config.CokeField.y, Config.CokeField.z, true) <= 20.0 and isHarvesting == false then
			DrawText3D(Config.CokeField.x, Config.CokeField.y, Config.CokeField.z + 1.0, 'Press [E] to harvest coke plant')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				isHarvesting = true
				TriggerEvent('esx:showNotification', 'Please wait while the coke is being harvested')
				runScenario("WORLD_HUMAN_GARDENER_PLANT", 'Harvesting coke...', Config.CokeFieldTime, function()
					TriggerServerEvent('krp_druglabs:harvestCoke')
					isHarvesting = false
				end)
			end
		end

		-- coke cutting (step 1)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeCutting.x, Config.CokeCutting.y, Config.CokeCutting.z, true) <= 2.0 and cokeStep == 0 then
			DrawText3D(Config.CokeCutting.x, Config.CokeCutting.y, Config.CokeCutting.z + 0.5, 'Press [E] to cut coke supplies')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				-- check for supplies. if they have supplies then startProcessing is called
				TriggerServerEvent('krp_druglabs:checkSupplies', 'coke')
			end
		end

		-- coke weighing (step 2)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokeWeighing.x, Config.CokeWeighing.y, Config.CokeWeighing.z, true) <= 1.0 and cokeStep == 1 then
			DrawText3D(Config.CokeWeighing.x, Config.CokeWeighing.y, Config.CokeWeighing.z + 0.5, 'Press [E] to weigh coke supplies')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				cokeStep = -1
				TriggerEvent('esx:showNotification', 'Please wait while the coke is being weighed')
				runScenario("WORLD_HUMAN_STAND_IMPATIENT",'Weighing coke...',  Config.CokeWeighingTime, function()
					TriggerEvent('esx:showNotification', 'The coke is now weighed')
					cokeStep = 2
				end)
			end
		end

		-- coke packaging (step 3)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.CokePackaging.x, Config.CokePackaging.y, Config.CokePackaging.z, true) <= 1.0 and cokeStep == 2 then
			DrawText3D(Config.CokePackaging.x, Config.CokePackaging.y, Config.CokePackaging.z + 0.5, 'Press [E] to package coke')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				cokeStep = -1
				TriggerEvent('esx:showNotification', 'Please wait while the coke is being packaged')
				runScenario("WORLD_HUMAN_STAND_IMPATIENT", 'Packaging coke...', Config.CokePackagingTime, function()
					TriggerEvent('esx:showNotification', 'The coke is now packaged')
					TriggerServerEvent('krp_druglabs:getDrug', 'coke')
					cokeStep = 0
				end)
			end
		end
		
		-- METH --
		-- meth lab entrance
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethEntrances[methEntrance].x, Config.MethEntrances[methEntrance].y, Config.MethEntrances[methEntrance].z, true) <= 3.0 then
			DrawText3D(Config.MethEntrances[methEntrance].x, Config.MethEntrances[methEntrance].y, Config.MethEntrances[methEntrance].z + 1.0, 'Press [E] to enter the meth lab')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				enterMethLab(ped)
			end
		end

		-- coke lab locked entrances --
		for i=1, #Config.MethEntrances, 1 do
			if i ~= methEntrance then
				if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethEntrances[i].x, Config.MethEntrances[i].y, Config.MethEntrances[i].z, true) <= 3.0 then
					DrawText3D(Config.MethEntrances[i].x, Config.MethEntrances[i].y, Config.MethEntrances[i].z + 1.0, 'This meth lab is currently closed')
					sleep = 0
				end
			end
		end
		
		-- meth lab exit
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethExit.x, Config.MethExit.y, Config.MethExit.z, true) <= 2.0 then
			DrawText3D(Config.MethExit.x, Config.MethExit.y, Config.MethExit.z + 1.0, 'Press [E] to leave the meth lab')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				exitMethLab(ped)
			end
		end

		-- meth supply
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethSupply.x, Config.MethSupply.y, Config.MethSupply.z, true) <= 1.0 then
			DrawText3D(Config.MethSupply.x, Config.MethSupply.y, Config.MethSupply.z + 1.0, 'Press [E] to purchase black market meth supplies ($' .. Config.MethSupplyPrice .. ')')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				TriggerServerEvent('krp_druglabs:buySupplies', 'meth')
			end
		end

		-- meth mixer (step 1)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethMixer.x, Config.MethMixer.y, Config.MethMixer.z, true) <= 1.0 and methStep == 0 then
			DrawText3D(Config.MethMixer.x, Config.MethMixer.y, Config.MethMixer.z + 0.5, 'Press [E] to mix meth supplies')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				-- check for supplies. if they have supplies then startProcessing is called
				TriggerServerEvent('krp_druglabs:checkSupplies', 'meth')
			end
		end

		-- meth purifier (step 2)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethPurifier.x, Config.MethPurifier.y, Config.MethPurifier.z, true) <= 1.0 and methStep == 1 then
			DrawText3D(Config.MethPurifier.x, Config.MethPurifier.y, Config.MethPurifier.z + 0.5, 'Press [E] to purify meth supplies')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				methStep = -1
				TriggerEvent('esx:showNotification', 'Please wait while the meth is being purified')
				runScenario("WORLD_HUMAN_STAND_IMPATIENT", 'Purifying meth...', Config.MethPurifierTime, function()
					TriggerEvent('esx:showNotification', 'The meth is now purified')
					methStep = 2
				end)
			end
		end

		-- meth furnace (step 3)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethFurnace.x, Config.MethFurnace.y, Config.MethFurnace.z, true) <= 1.0 and methStep == 2 then
			DrawText3D(Config.MethFurnace.x, Config.MethFurnace.y, Config.MethFurnace.z + 0.5, 'Press [E] to cook meth supplies')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				methStep = -1
				TriggerEvent('esx:showNotification', 'Please wait while the meth is cooking')
				runScenario("WORLD_HUMAN_STAND_IMPATIENT", 'Cooking meth...', Config.MethFurnaceTime, function()
					TriggerEvent('esx:showNotification', 'The meth is now cooked')
					methStep = 3
				end)
			end
		end

		-- meth break and package (step 4)
		if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, Config.MethTable.x, Config.MethTable.y, Config.MethTable.z, true) <= 1.0 and methStep == 3 then
			DrawText3D(Config.MethTable.x, Config.MethTable.y, Config.MethTable.z + 0.5, 'Press [E] to break up and package meth')
			sleep = 0
			if IsControlJustPressed(0, 38) then
				methStep = -1
				TriggerEvent('esx:showNotification', 'Please wait while the meth is broken up and packaged')
				runScenario("WORLD_HUMAN_HAMMERING", 'Breaking up and packaging meth...', Config.MethTableTime, function()
					TriggerEvent('esx:showNotification', 'The meth is now broken up and packaged')
					TriggerServerEvent('krp_druglabs:getDrug', 'meth')
					methStep = 0
				end)
			end
		end

		Citizen.Wait(sleep)
		
	end
end)


-- enter/exit functions
function enterMethLab(ped)
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(ped, Config.MethExit.x, Config.MethExit.y, Config.MethExit.z)
	DoScreenFadeIn(1000)
end

function exitMethLab(ped)
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	
	SetEntityCoords(ped, Config.MethEntrances[methEntrance].x, Config.MethEntrances[methEntrance].y, Config.MethEntrances[methEntrance].z)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end

function enterCokeLab(ped)
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(ped, Config.CokeExit.x, Config.CokeExit.y, Config.CokeExit.z)
	DoScreenFadeIn(1000)
end

function exitCokeLab(ped)
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)

	SetEntityCoords(ped, Config.CokeEntrances[cokeEntrance].x, Config.CokeEntrances[cokeEntrance].y, Config.CokeEntrances[cokeEntrance].z)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end


function runScenario(scenario, label, ticks, cb)
	TriggerEvent("mythic_progbar:client:progress", {
        name = label,
        duration = ticks,
        label = label,
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = nil,
			anim = nil,
			task = scenario
        },
        prop = {
            model = nil
        }
    }, function(status)
        if not status then
            -- Do Something If Event Wasn't Cancelled
		end
		cb()
    end)
end

function DrawText3D(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
  
	local scale = 0.45
   
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0150, 0.030 + factor , 0.030, 66, 66, 66, 150)
	end
end