ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingKoda    = {}
local PlayersTransformingKoda  = {}
local PlayersSellingKoda       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

--kodeina
local function HarvestKoda(source)

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local koda = xPlayer.getInventoryItem('apple')

			if koda.limit ~= -1 and koda.count >= koda.limit then
				TriggerClientEvent('esx:showNotification', source, _U('bag_full'))
			else
				xPlayer.addInventoryItem('apple', 1)
				HarvestKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmapple:startHarvestKoda')
AddEventHandler('esx_farmapple:startHarvestKoda', function()
	local _source = source

	if not PlayersHarvestingKoda[_source] then
		PlayersHarvestingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('take_apple'))
		HarvestKoda(_source)
	else
		print(('esx_farmapple: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmapple:stopHarvestKoda')
AddEventHandler('esx_farmapple:stopHarvestKoda', function()
	local _source = source

	PlayersHarvestingKoda[_source] = false
end)

local function TransformKoda(source)

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local kodaQuantity = xPlayer.getInventoryItem('apple').count
			local pooch = xPlayer.getInventoryItem('juice_apple')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('you_do_not_have_enough_Apple'))
			elseif kodaQuantity < 5 then
				TriggerClientEvent('esx:showNotification', source, _U('iyou_do_not_have_any_more_Apple'))
			else
				xPlayer.removeInventoryItem('apple', 2)
				xPlayer.addInventoryItem('juice_apple', 1)

				TransformKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmapple:startTransformKoda')
AddEventHandler('esx_farmapple:startTransformKoda', function()
	local _source = source

	if not PlayersTransformingKoda[_source] then
		PlayersTransformingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('transform_juice_apple'))
		TransformKoda(_source)
	else
		print(('esx_farmapple: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmapple:stopTransformKoda')
AddEventHandler('esx_farmapple:stopTransformKoda', function()
	local _source = source

	PlayersTransformingKoda[_source] = false
end)

local function SellKoda(source)

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('juice_apple').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('you_do_not_have_juice_apple'))
			else
				xPlayer.removeInventoryItem('juice_apple', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('bank', 10)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('bank', 50)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('bank', 50)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('bank', 50)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('bank', 50)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('bank', 50)
					TriggerClientEvent('esx:showNotification', source, _U('sell_juice'))
				end

				SellKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_farmapple:startSellKoda')
AddEventHandler('esx_farmapple:startSellKoda', function()
	local _source = source

	if not PlayersSellingKoda[_source] then
		PlayersSellingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('sell_juice_apple'))
		SellKoda(_source)
	else
		print(('esx_farmapple: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_farmapple:stopSellKoda')
AddEventHandler('esx_farmapple:stopSellKoda', function()
	local _source = source

	PlayersSellingKoda[_source] = false
end)

RegisterServerEvent('esx_farmapple:GetUserInventory')
AddEventHandler('esx_farmapple:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_farmapple:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('apple').count,
		xPlayer.getInventoryItem('juice_apple').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('apple', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('apple', 1)

	TriggerClientEvent('esx_farmapple:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_koda'))
end)
