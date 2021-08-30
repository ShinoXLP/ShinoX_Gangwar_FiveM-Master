local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }


local weaponhashes = {2725352035, 4194021054, 148160082, 2578778090, 1737195953, 1317494643, 2508868239, 1141786504, 2227010557, 453432689, 1593441988, 584646201, 2578377531, 324215364, 736523883, 4024951519, 3220176749, 2210333304, 2937143193, 2634544996, 2144741730, 487013001, 2017895192, 3800352039, 2640438543, 911657153, 100416529, 205991906, 856002082, 2726580491, 1305664598, 2982836145, 1752584910, 101631238, 1233104067}

local pweapons = {}



ESX                           = nil

local PlayerData              = {}

ESX = nil

Citizen.CreateThread(function ()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1)
    end

    while ESX.GetPlayerData() == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('setJob')
AddEventHandler('setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand('heiner', function()
	
	EnterZone()



end)

RegisterCommand('heiner2', function()
	


	LeaveZone()

end)

Citizen.CreateThread(function()
	Citizen.Wait(2000)
TriggerServerEvent('esx_gangwar:setBlip')
end)

RegisterNetEvent('esx_gangwar:setBlip')
AddEventHandler('esx_gangwar:setBlip', function(blips)
	for i=1, #blips do
		local blip = AddBlipForCoord(json.decode(blips[i].coords).x, json.decode(blips[i].coords).y, json.decode(blips[i].coords).z)
		SetBlipSprite(blip, 543)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Fraktionsgebiet von: " .. blips[i].frak:gsub("^%l", string.upper)) 
		EndTextCommandSetBlipName(blip)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)
	end
end)

function EnterZone()
	local ped = GetPlayerPed(-1)
	for i = 1, #weaponhashes do

		if HasPedGotWeapon(ped, weaponhashes[i], false) then
			table.insert(pweapons, {hash = weaponhashes[i], ammo = GetAmmoInPedWeapon(ped, weaponhashes[i])})
		end
	end

	RemoveAllPedWeapons(ped, false)

	for i = 1, #Config.Weapons do

		GiveWeaponToPed(ped, Config.Weapons[i], 1000, false, false)


	end
end


function LeaveZone()
	local ped = GetPlayerPed(-1)
	RemoveAllPedWeapons(ped, false)

	if pweapons ~= nil then
		for i = 1, #pweapons do
			print(pweapons[i].ammo)
			GiveWeaponToPed(ped, pweapons[i].hash, pweapons[i].ammo, false, false)
		end
		pweapons = {}
	end

end

local flagge = nil
local IsInDimension = false
Citizen.CreateThread(function()
	



while true do
	Citizen.Wait(0)
	local pedcoords = GetEntityCoords(GetPlayerPed(-1))
for i = 1, #Config.flags do	
	DrawMarker(4, Config.ZoneCoords[Config.flags[i]].coords, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 255, 136, 0, 140, false, true, 2, false, nil, nil, false)

end
	
	if IsInDimension then
		
		DrawMarker(28, Config.ZoneCoords[flagge].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 150.0, Config.ZoneCoords[flagge].scale[1], Config.ZoneCoords[flagge].scale[2], Config.ZoneCoords[flagge].scale[3], 255, 165, 0, 255, false, false, 2, false, nil, nil, false)
	else
		for i = 1, #Config.flags do 
			if GetDistanceBetweenCoords(Config.ZoneCoords[Config.flags[i]].coords, pedcoords, true) <= 0.75 then
				ESX.ShowHelpNotification('Drücke ~INPUT_PICKUP~ um das Gang Gebiet einzunehmen')
				if IsControlJustReleased(0, Keys['E']) then
					TriggerServerEvent('esx_gangwar:getFlag', Config.ZoneCoords[Config.flags[i]])
					
				end
			end
		end		
	end	
end
end)



Citizen.CreateThread(function()
while true do
Citizen.Wait(0)
local ped = GetPlayerPed(-1)
local coords = GetEntityCoords(ped)

	for i=1, #Config.Fraklist do
	  if ESX.PlayerData.job.name == Config.Fraklist[i] then
		
		DrawMarker(1, Config.Fraks[ESX.PlayerData.job.name].coords.x, Config.Fraks[ESX.PlayerData.job.name].coords.y, Config.Fraks[ESX.PlayerData.job.name].coords.z - 1, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, Config.Fraks[ESX.PlayerData.job.name].rgb.r, Config.Fraks[ESX.PlayerData.job.name].rgb.g, Config.Fraks[ESX.PlayerData.job.name].rgb.b, 140, false, false, 2, false, nil, nil, false)
		if GetDistanceBetweenCoords(coords, Config.Fraks[ESX.PlayerData.job.name].coords, true) <= 0.75 then
			ESX.ShowHelpNotification('Drücke ~input_pickup~ um das Gangwargebiet zu betreten!')
			if IsControlJustReleased(0, Keys['E']) then
				if not IsInDimension then
					TriggerServerEvent('esx_gangwar:enterDimension')
				elseif IsInDimension then
					TriggerServerEvent('esx_gangwar:leaveDimension')
				end	
			end
		end
	  end	
	end
end
end)

RegisterNetEvent('esx_gangwar:showNUI')
AddEventHandler('esx_gangwar:showNUI', function(color1, color2, job2, job1, bildl, bildr)


	SendNUIMessage({
		type = 'ui',
		punkte = false,
		status = true,
		color1 = color1,
		color2 = color2,
		job1 = job1,
		job2 = job2,
		bildr = bildr,
		bildl = bildl,

	})



end)

RegisterNetEvent('esx_gangwar:enterDimension')
AddEventHandler('esx_gangwar:enterDimension', function(_flagge)

	flagge = _flagge
	IsInDimension = true
	TriggerEvent('esx_gangwargarage:openGarage')
	--AddBlipForCoord()

end)

RegisterNetEvent('esx_gangwar:leaveDimension')
AddEventHandler('esx_gangwar:leaveDimension', function(_flagge)

	flagge = nil
	IsInDimension = false



end)

AddEventHandler('onResourceStart', function()

	SendNUIMessage({
		type = 'ui',
		status = false,
	})

--[[Citizen.Wait(1000)
	SendNUIMessage({
		type = 'ui',
		punkte = false,
		status = true,
		color1 = '#ffffff',
		color2 = '#ffffff',
		job1 = 'ballas',
		job2 = 'ballas',
		bildr = 'grove',
		bildl = 'vagos',

	})-]]

end)

RegisterNetEvent('esx_gangwar:closeNUI')
AddEventHandler('esx_gangwar:closeNUI', function()

	SendNUIMessage({
		type = 'ui',
		status = false,

	})

end)

local prechts = 0
local plinks = 0
  Citizen.CreateThread(function()
while true do
Citizen.Wait(1000)

	if IsInDimension then
		SendNUIMessage({
			type = 'ui',
			punkte = true,
			status = true,
			plinks = plinks,
			prechts = prechts,


		})
	end

end
  end)

AddEventHandler('hoodlife:onPlayerDeath', function(data)
	if IsInDimension then
		if data.killedByPlayer then
			local killer = data.killerServerId
	
			TriggerServerEvent('esx_gangwar:killed', killer)
			
		end	
	end

end)

RegisterNetEvent('esx_gangwar:setPoints')
AddEventHandler('esx_gangwar:setPoints', function(teamkill, seite)

	if seite == 'links' then
		if teamkill then
			plinks = plinks - 3
		elseif not teamkill then
			plinks = plinks + 3
		end
	elseif seite == 'rechts' then
		if teamkill then
			prechts = prechts - 3
		elseif not teamkill then
			prechts = prechts + 3
		end
	end
end)

Citizen.CreateThread(function()
local IsOutZone = false
local IsInZone = false

while true do
Citizen.Wait(0)
	if flagge ~= nil then
		local coords = GetEntityCoords(GetPlayerPed(-1))
		local distance = GetDistanceBetweenCoords(Config.ZoneCoords[flagge].coords, coords, false)
		if distance > Config.ZoneCoords[flagge].scale[1] and not IsOutZone then
			IsOutZone = true
			IsInZone = false
			LeaveZone()
			print('heiner')
		elseif distance <  Config.ZoneCoords[flagge].scale[1] and not IsInZone then
			IsInZone = true
			IsOutZone = false
			EnterZone()

		end
	end
end
end)
