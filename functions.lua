FunctionsVersion = 1.5  --! por favor não altere aqui! | please do not change here!
Functions = {}
Events = {}

--todo: Configure alguns eventos para que funcione com o seu servidor aqui! | Set up some events to make it work with your server here!!
if not IsDuplicityVersion() then  --? client
	RegisterNetEvent("striata:truck:truckSpawned")
	AddEventHandler("striata:truck:truckSpawned",function(entity,plate,netId,locked)
		--! Coloque aqui eventos ou exports no lado do client para garagens com função de desligamento de veiculos. | Enter client-side events or exports here for garages with a vehicle shutdown function.
		TriggerServerEvent("striata:truck:truckSpawned",plate,netId,locked)
		
		TriggerServerEvent("registerVehicleInRegister",netId)
	end)
else  --? Server
	--! Coloque aqui eventos ou exports no lado do servidor para garagens com função de desligamento de veiculos. | Place server-side events or exports here for garages with vehicle shutdown function.
	RegisterNetEvent("striata:truck:truckSpawned")
	AddEventHandler("striata:truck:truckSpawned",function(plate,netId,locked)
		--exports["nation-garages"]:toggleVehicleEngine(netId)
	end)
end

--todo: Configure as funções do seu de servidor aqui! | Configure your server functions here!
Functions.vRP = {
	client = {
		getSharedObject = function()
			local Proxy = module("vrp","lib/Proxy")
		
			return {
				Proxy = module("vrp","lib/Proxy"),
				Tunnel = module("vrp","lib/Tunnel"),
				vRP = Proxy.getInterface("vRP"),
			}
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getOutfit = function()
			return vRP.getCustomization()
		end,

		setOutfit = function(outfit)
			return vRP.setCustomization(outfit)
		end,

		setPlayerHandcuffed = function(toggle)
			return vRP.setHandcuffed(toggle)
		end,

		teleportPlayer = function(x,y,z)
			return vRP.teleport(x,y,z)
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		getNearestVehicles = function(radius)
			return vRP.getNearestVehicles(radius)
		end,

		getNearestVehicle = function(radius)
			return vRP.getNearestVehicle(radius)
		end,
		
		getNearestPlayer = function(radius)
			return vRP.getNearestPlayer(radius)
		end,

		killGod = function()
			return vRP.killGod()
		end,
	
		setHealth = function(health)
			return vRP.setHealth(health)
		end,

		addBlip = function(x,y,z,idtype,idcolor,text,scale,route)
			local blip = AddBlipForCoord(x,y,z)
			SetBlipSprite(blip,idtype)
			SetBlipAsShortRange(blip,true)
			SetBlipColour(blip,idcolor)
			SetBlipScale(blip,scale)

			if route then
				SetBlipRoute(blip,true)
			end

			if text then
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(text)
				EndTextCommandSetBlipName(blip)
			end
			return blip
		end,

		removeBlip = function(blipId)
			RemoveBlip(id)
		end,
	},

	server = {
		getSharedObject = function()
			local Proxy = module("vrp","lib/Proxy")
			local Tunnel = module("vrp","lib/Tunnel")

			return {
				Proxy = module("vrp","lib/Proxy"),
				Tunnel = module("vrp","lib/Tunnel"),
				vRP = Proxy.getInterface("vRP"),
				vRPclient = Tunnel.getInterface("vRP")
			}
		end,

		exports = function(...)
			local args = {...}
			return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
		end,

		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end
			return vRP.getUserIdByIdentifiers(identifiers)
		end,
		
		getUserId = function(source)
			return vRP.getUserId(source)
		end,

		getUserSource = function(user_id)
			return vRP.getUserSource(parseInt(user_id))
		end,

		getUsers = function()
			return vRP.getUsers()
		end,

		getUsersByPermission = function(perm)
			return vRP.getUsersByPermission(perm)
		end,

		hasPermission = function(user_id, perm)
			return vRP.hasPermission(parseInt(user_id), perm)
		end,

		getUserGroups = function(user_id)
			local userGroupsFormat = {}
			if vRP.getUserSource(parseInt(user_id)) then
				local userGroups = vRP.getUserGroups(parseInt(user_id))
				for group,status in pairs(userGroups) do
					if status then
						userGroupsFormat[group] = { hierarchyName = "" }
					end
				end
				return userGroupsFormat
			else
				local userGroups = {}

				local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_data WHERE user_id = @user_id AND dkey = @dkey", {
                    ['@user_id'] = user_id,
                    ['@dkey'] = "vRP:datatable"
                })

				if rows[1] then
					local dvalue = json.decode(rows[1].dvalue)
					userGroups = dvalue.groups
				end

				for group,status in pairs(userGroups) do
					if status then
						userGroupsFormat[group] = { hierarchyName = "" }
					end
				end
				return userGroupsFormat
			end
		end,

		getAllUserGroups = function()
			local allUserGroups = {}
			local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_data WHERE dkey = @dkey",{
				['@dkey'] = "vRP:datatable"
			})

			for rowNumber,rowInfos in pairs(rows) do
				local user_id = rowInfos.user_id
				local dataTable = json.decode(rowInfos.dvalue)
				local userGroups = dataTable.groups
				for group,enable in pairs(userGroups) do
					if enable then
						if not allUserGroups[group] then
							allUserGroups[group] = {}
						end
						table.insert( allUserGroups[group], { user_id = user_id, hierarchyName = "" } )
					end
				end
			end

			return allUserGroups
		end,

		addUserGroup = function(user_id,group)
			if vRP.getUserSource(parseInt(user_id)) then
				return vRP.addUserGroup(parseInt(user_id),group)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				if dataTable and dataTable.groups then
					if not dataTable.groups[group] then
						dataTable.groups[group] = true
						return vRP._setUData(user_id, "vRP:datatable", json.encode(dataTable))
					end
				end
			end
		end,

		removeUserGroup = function(user_id,group)
			if vRP.getUserSource(parseInt(user_id)) then
				return vRP.removeUserGroup(parseInt(user_id),group)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				if dataTable and dataTable.groups then
					if dataTable.groups[group] then
						dataTable.groups[group] = nil
						return vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					end
				end
			end
		end,

		request = function(source, text, time)	  
			return vRP.request(source, text, time)
		end,

		textInput = function(source,text, input)
			return vRP.prompt(source,text, input)
		end,

		giveHandMoney = function(user_id, amount)
			return vRP.giveMoney(parseInt(user_id),amount)
		end,

		removeHandMoney = function(user_id, amount)
			return vRP.tryPayment(parseInt(user_id),amount)
		end,

		giveBankMoney = function(user_id, amount)
			return vRP.giveBankMoney(parseInt(user_id),amount)
		end,

		removeBankMoney = function(user_id, amount)
			return vRP.tryFullPayment(parseInt(user_id),amount)
		end,

		getInventoryItems = function(user_id,item)
			local itemsTable = {}

			local inventory = {}

			if vRP.getUserSource(parseInt(user_id)) then
				inventory = vRP.getInventory(parseInt(user_id))
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				inventory = dataTable.inventory
			end

			for item, amountTable in pairs(inventory) do
				itemsTable[item] = amountTable.amount
			end

			return itemsTable
		end,

		getInventoryItemAmount = function(user_id,item)
			if vRP.getUserSource(parseInt(user_id)) then
				return vRP.getInventoryItemAmount(parseInt(user_id),item)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				inventory = dataTable.inventory
				if inventory[item] then
					return inventory[item].amount
				else
					return 0
				end
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			if vRP.getUserSource(parseInt(user_id)) then
				return vRP.giveInventoryItem(parseInt(user_id),item,amount,true)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				inventory = dataTable.inventory or {}
				if inventory[item] then
					inventory[item] = inventory[item].amount + amount
				else
					inventory[item] = {amount = amount}
				end

				dataTable.inventory = inventory
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))

				return true
			end

			return false
		end,

		removeInventoryItem = function(user_id,item,amount)
			if vRP.getUserSource(parseInt(user_id)) then
				return vRP.tryGetInventoryItem(parseInt(user_id),item,amount,true)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				inventory = dataTable.inventory or {}
				if inventory[item] then
					inventory[item] = nil

					dataTable.inventory = inventory
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				else
					return false
				end
			end
		end,

		getInventoryWeight = function(user_id)
			return vRP.getInventoryWeight(parseInt(user_id))
		end,

		getInventoryMaxWeight = function(user_id)
			return vRP.getInventoryMaxWeight(parseInt(user_id))
		end,

		getItemWeight = function(item)
			return vRP.getItemWeight(item)
		end,

		getItemName = function(item)
			return vRP.itemNameList(item)
		end,

		getItemIndex = function(item)
			return vRP.itemIndexList(item)
		end,

		giveVehicle = function(user_id,vehicle)
			return MySQL.Sync.fetchAll("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)", {
				["@user_id"] = user_id,
				["@vehicle"] = vehicle,
				["@ipva"] = parseInt(os.time())
			})
		end,

		removeVehicle = function(user_id,vehicle)
			return MySQL.Sync.fetchAll("DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle", {
				["@user_id"] = user_id,
				["@vehicle"] = vehicle,
			})
		end,

		saveOutfit = function(source,outfit)
			return vRP.save_idle_custom(source,outfit)
		end,

		removeOutfit = function(source)
			return vRP.removeCloak(source)
		end,

		getArrestPoliceTime = function(user_id)
			return vRP.getUData(parseInt(user_id),"vRP:prisao")
		end,

		setArrestPoliceTime = function(user_id,time)
			return vRP.setUData(parseInt(user_id),"vRP:prisao",json.encode(parseInt(time)))
		end,

		getFines = function(user_id)
			return vRP.getUData(parseInt(user_id),"vRP:multas")
		end,

		setFine = function(user_id,value)
			return vRP.setUData(parseInt(user_id),"vRP:multas",json.encode(parseInt(value)))
		end,

		getUserInfo = function(user_id)
			local info = {}
			if vRP.getUserSource(parseInt(user_id)) then
				local identity = vRP.getUserIdentity(parseInt(user_id))
				info["name"] = identity.name
				info["lastName"] = identity.firstname
				info["age"] = identity.age
				info["document"] = identity.registration
				info["phone"] = identity.phone
				return info
			else
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_identities WHERE user_id = @user_id", {
					["@user_id"] = user_id,
				})
				identity = playerInfos[1]
				info["name"] = identity.name
				info["lastName"] = identity.firstname
				info["age"] = identity.age
				info["document"] = identity.registration
				info["phone"] = identity.phone
				return info
			end
		end,

		bannedPlayer = function(user_id,toogle)
			if not toogle then
				toogle = true
			end

			return MySQL.Sync.fetchAll("UPDATE vrp_users SET banned = @banned WHERE id = @user_id", {
				["@user_id"] = parseInt(user_id),
				["@banned"] = toogle,
			})
		end,

		setHealth = function(user_id,amount)
			local source = vRP.getUserSource(parseInt(user_id))
			if source then
				vRPclient.setHealth(source,amount)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				dataTable.health = amount
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
			end
		end,

		setArmour = function(user_id,amount)
			local source = vRP.getUserSource(parseInt(user_id))
			if source then
				vRPclient.setArmour(source,amount)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				dataTable.colete = amount
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
			end
		end,

		setHunger = function(user_id,amount)
			local source = vRP.getUserSource(parseInt(user_id))
			if source then
				vRP.setHunger(parseInt(user_id),amount)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				dataTable.hunger = amount
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
			end
		end,

		setThirst = function(user_id,amount)
			local source = vRP.getUserSource(parseInt(user_id))
			if source then
				vRP.setThirst(parseInt(user_id),amount)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				dataTable.thirst = amount
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
			end
		end,

		setStress = function(user_id,amount)
			local source = vRP.getUserSource(parseInt(user_id))
			if source then
				vRP.setStress(parseInt(user_id),amount)
			else
				local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
				dataTable.stress = amount
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
			end
		end,
		
		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			if user_id and homeName	then
				local table = MySQL.Sync.fetchAll("SELECT * FROM vrp_homes_permissions WHERE user_id = @user_id", {
					["@user_id"] = user_id,
				})
				if table and #table > 0 then
					for v in ipairs(table) do 
						if table[v].home == homeName then
							return true
						end
					end
				end
				TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
				return false
			end
		end,

		getWhiteListStatus = function(user_id,status)
			return vRP.isWhitelisted(parseInt(user_id))
		end,

		changeWhiteListStatus = function(user_id,status)
			vRP.setWhitelisted(parseInt(user_id),status)
			return vRP.setWhitelisted(parseInt(user_id),status)
		end,

		getBanStatus = function(user_id)
			return vRP.isBanned(parseInt(user_id))
		end,

		setBanStatus = function(user_id,status,reason)
			local source = vRP.getUserSource(parseInt(user_id))
			if status and source then
				DropPlayer(source, reason)
			end
			return vRP.setBanned(parseInt(user_id),status)
		end
	}
}

Events.vRP = {
	client = {
		playerSpawn = "tvRP:playerSpawnNow"
	},
	server = {
		playerSpawn = "vRP:playerSpawn"
	}
}

Functions.ESX = {
	client = {
		getSharedObject = function()
			return exports['es_extended']:getSharedObject()
		end,
		
		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		request = function(text, time)
			local currentTime = os.time()
			local Elements = {
				{
					icon = "",
					title = text,
					unselectable = true
				},
				{
					icon = "fas fa-check",
					title = "Sim",
					value = "yes"
				},
				{
					icon = "fa-solid fa-xmark",
					title = "Não",
					value = "no"
				}
			}
		
			local resp = ""
			exports["esx_context"]:Open("right", Elements, function(menu, element)
		
				if element.value == "yes" then
					exports["esx_context"]:Close()
					resp = true
				end
				if element.value == "no" then
					exports["esx_context"]:Close()
					resp = false
				end
			end)

			local currentTime2 = os.time()
			repeat
				Wait(50)

				currentTime2 = os.time()
				if (currentTime + time) - os.time() then
					exports["esx_context"]:Close()
				end
			until(resp ~= "" or ((currentTime + time) - currentTime2) <= 0)

			return resp
		end,

		textInput = function(text, input)
			local keyboard, cb = exports["nh-keyboard"]:Keyboard({header = text, rows = {input}})
			return cb
		end,
		
		getOutfit = function()
			local ped = PlayerPedId()
			local custom = {}
			custom.modelhash = GetEntityModel(ped)
		
			for i = 0,20 do
				custom[i] = { GetPedDrawableVariation(ped,i),GetPedTextureVariation(ped,i),GetPedPaletteVariation(ped,i) }
			end
		
			for i = 0,10 do
				custom["p"..i] = { GetPedPropIndex(ped,i),math.max(GetPedPropTextureIndex(ped,i),0) }
			end
			return custom
		end,

		getWeapons = function()
			local player = PlayerPedId()
			local ammo_types = {}
			local weapons = {}
			local weapon_types = { "WEAPON_DAGGER","WEAPON_BAT","WEAPON_BOTTLE","WEAPON_CROWBAR","WEAPON_FLASHLIGHT","WEAPON_GOLFCLUB","WEAPON_HAMMER","WEAPON_HATCHET","WEAPON_KNUCKLE","WEAPON_KNIFE","WEAPON_MACHETE","WEAPON_SWITCHBLADE","WEAPON_NIGHTSTICK","WEAPON_WRENCH","WEAPON_BATTLEAXE","WEAPON_POOLCUE","WEAPON_STONE_HATCHET","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_STUNGUN","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_SNSPISTOL_MK2","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_REVOLVER_MK2","WEAPON_DOUBLEACTION","WEAPON_RAYPISTOL","WEAPON_CERAMICPISTOL","WEAPON_NAVYREVOLVER","WEAPON_GADGETPISTOL","WEAPON_STUNGUN_MP","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_COMBATPDW","WEAPON_MACHINEPISTOL","WEAPON_MINISMG","WEAPON_RAYCARBINE","WEAPON_PUMPSHOTGUN","WEAPON_PUMPSHOTGUN_MK2","WEAPON_SAWNOFFSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_AUTOSHOTGUN","WEAPON_COMBATSHOTGUN","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_SPECIALCARBINE_MK2","WEAPON_BULLPUPRIFLE","WEAPON_BULLPUPRIFLE_MK2","WEAPON_COMPACTRIFLE","WEAPON_MILITARYRIFLE","WEAPON_HEAVYRIFLE","WEAPON_TACTICALRIFLE","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_GUSENBERG","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_MARKSMANRIFLE_MK2","WEAPON_PRECISIONRIFLE","WEAPON_RPG","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_MINIGUN","WEAPON_FIREWORK","WEAPON_RAILGUN","WEAPON_HOMINGLAUNCHER","WEAPON_COMPACTLAUNCHER","WEAPON_RAYMINIGUN","WEAPON_EMPLAUNCHER","WEAPON_GRENADE","WEAPON_BZGAS","WEAPON_MOLOTOV","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_SNOWBALL","WEAPON_PIPEBOMB","WEAPON_BALL","WEAPON_SMOKEGRENADE","WEAPON_FLARE","WEAPON_PETROLCAN","GADGET_PARACHUTER","WEAPON_FIREEXTINGUISHER","WEAPON_HAZARDCAN","WEAPON_FERTILIZERCAN" }
			for k,v in pairs(weapon_types) do
				local hash = GetHashKey(v)
				if HasPedGotWeapon(player,hash) then
					local weapon = {}
					weapons[v] = weapon
					local atype = GetPedAmmoTypeFromWeapon(player,hash)
					if ammo_types[atype] == nil then
						ammo_types[atype] = true
						weapon.ammo = GetAmmoInPedWeapon(player,hash)
					else
						weapon.ammo = 0
					end
				end
			end
		
			return weapons
		end,

		giveWeapons = function(weapons,clearBefore)
			local player = PlayerPedId()
			if clearBefore then
				RemoveAllPedWeapons(player,true)
				weapon_list = {}
			end
		
			for k,weapon in pairs(weapons) do
				local hash = GetHashKey(k)
				local ammo = weapon.ammo or 0
				GiveWeaponToPed(player,hash,ammo,false)
				weapon_list[k] = weapon
			end
		end,

		setOutfit = function(outfit)
			if outfit then
				local ped = PlayerPedId()
				local mhash = nil
				local maxHealt = GetPedMaxHealth(ped)
				
				if outfit.modelhash then
					mhash = outfit.modelhash
				elseif outfit.model then
					mhash = GetHashKey(outfit.model)
				end
	
				if mhash then
					local i = 0
					while not HasModelLoaded(mhash) and i < 10000 do
						RequestModel(mhash)
						Citizen.Wait(10)
					end
	
					if HasModelLoaded(mhash) then
						local weapons = Functions["client"].getWeapons()
						local armour = GetPedArmour(ped)
						local health = GetEntityHealth(ped)
						SetPlayerModel(PlayerId(),mhash)

						ped = PlayerPedId()

						SetPedMaxHealth(ped,maxHealt)
						SetEntityHealth(ped,health)
						Functions["client"].giveWeapons(weapons,true)
						SetPedArmour(ped,armour)
						SetModelAsNoLongerNeeded(mhash)
					end
				end
	
				for k,v in pairs(outfit) do
					if k ~= "model" and k ~= "modelhash" then
						local function parse_part(key)
							if type(key) == "string" and string.sub(key,1,1) == "p" then
								return true,tonumber(string.sub(key,2))
							else
								return false,tonumber(key)
							end
						end

						local isprop, index = parse_part(k)

						if isprop then
							if v[1] < 0 then
								ClearPedProp(ped,index)
							else
								SetPedPropIndex(ped,index,v[1],v[2],v[3] or 2)
							end
						else
							SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
						end							
					end
				end
			end
		end,

		setPlayerHandcuffed = function(toggle)
			if IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 3) ~= 1 and toggle == true then
				TriggerEvent('esx_policejob:handcuff')
			elseif IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 3) == 1 and toggle == false then
				TriggerEvent('esx_policejob:handcuff')
			end
		end,

		teleportPlayer = function(x,y,z)
			SetEntityCoords(PlayerPedId(), vector3(x,y,z), false, false, false, false)
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		getNearestVehicles = function(radius)
			local vehicles = {}
			local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))
		
			local vehs = {}
			local it,veh = FindFirstVehicle()
			if veh then
				table.insert(vehs,veh)
			end
			local ok
			repeat
				ok,veh = FindNextVehicle(it)
				if ok and veh then
					table.insert(vehs,veh)
				end
			until not ok
			EndFindVehicle(it)
		
			for n,veh in pairs(vehs) do
				local x,y,z = table.unpack(GetEntityCoords(veh))
				local distance = Vdist(x,y,z,px,py,pz)
				if distance <= radius then
					vehicles[veh] = distance
				end
			end
			return vehicles
		end,

		getNearestVehicle = function(radius)
			local vehicle
			local vehicles = Functions["client"].getNearestVehicles(radius)
			local min = radius+0.0001
			for veh,dist in pairs(vehicles) do 
				if dist < min then
					min = dist
					vehicle = veh
				end
			end
			return vehicle
		end,
		
		getNearestPlayers = function(radius)
			local allPlayers = QBCore.Functions.GetPeds()
			local players = {}
			for n,player in pairs(allPlayers) do
				local coords = GetEntityCoords(PlayerPedId())
				local pedCoords = GetEntityCoords(player)
				local distance = #(pedCoords - coords)
				players[GetPlayerServerId(player)] = distance
			end
			return players
		end,

		getNearestPlayer = function(radius)
			local player, distance = ESX.Game.GetClosestPlayer()
			if distance <= radius then
				return GetPlayerServerId(player)
			end
			return false
		end,

		killGod = function()
			TransitionFromBlurred(1000)
			nocauteado = false
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			SetEntityHealth(ped,120)
			ClearPedTasks(ped)
			ClearPedSecondaryTask(ped)
		end,
	
		setHealth = function(health)
			return SetEntityHealth(PlayerPedId(),tonumber(health))
		end,

		addBlip = function(x,y,z,idtype,idcolor,text,scale,route)
			local blip = AddBlipForCoord(x,y,z)
			SetBlipSprite(blip,idtype)
			SetBlipAsShortRange(blip,true)
			SetBlipColour(blip,idcolor)
			SetBlipScale(blip,scale)

			if route then
				SetBlipRoute(blip,true)
			end

			if text then
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(text)
				EndTextCommandSetBlipName(blip)
			end
			return blip
		end,

		removeBlip = function(blipId)
			RemoveBlip(id)
		end,
	},

	server = {
		getSharedObject = function()
			return exports['es_extended']:getSharedObject()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserId = function(source)
			local player = ESX.GetPlayerFromId(source)
			if player then
				return player.identifier
			end
		end,

		getUserSource = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.playerId
			end
		end,

		getUsers = function()
			local users = {}
			for k,v in pairs(ESX.GetPlayers()) do
				users[ESX.GetPlayerFromId(v).identifier] = v
			end
			return users
		end,

		getUsersByPermission = function(perm)
			local users = {}
			for k,v in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(v))
				if Functions["server"].hasPermission(user_id,perm) then
					table.insert(users,user_id)
				end
			end
			return users
		end,

		hasPermission = function(user_id,perm)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				if ESX.GetPlayerFromId(player.playerId).job.name == perm or ESX.GetPlayerFromId(player.playerId).group == perm then
					return true
				else
					return false
				end
			else
				return false
			end
		end,

		getUserGroups = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return ESX.GetPlayerFromId(player.playerId).job
			end
		end,
		
		addUserGroup = function(user_id,group)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.setJob(group,1)
			end
		end,

		removeUserGroup = function(user_id,group)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.setJob("unemployed", 0)
			else
				return MySQL.Sync.fetchAll('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, 0, user_id})
			end
		end,
		
		giveHandMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.addAccountMoney("money",amount)
			else
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				userAccounts.money = userAccounts.money + amount
				return MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@accounts"] = json.encode(userAccounts),
				})
			end
		end,

		removeHandMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.removeAccountMoney('money', amount)
			else
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				userAccounts.money = userAccounts.money - amount
				return MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@accounts"] = json.encode(userAccounts),
				})
			end
		end,

		giveBankMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.addAccountMoney("bank",amount)
			else
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				userAccounts.bank = userAccounts.bank + amount
				return MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@accounts"] = json.encode(userAccounts),
				})
			end
		end,

		removeBankMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.removeAccountMoney('bank', amount)
			else
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				userAccounts.bank = userAccounts.bank - amount
				return MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@accounts"] = json.encode(userAccounts),
				})
			end
		end,

		getInventoryItemAmount = function(user_id,item)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				if player.getInventoryItem(item) then
					return player.getInventoryItem(item).count
				else
					return 0
				end
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.addInventoryItem(item,amount)
			end
		end,

		removeInventoryItem = function(user_id,item,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				if player.getInventoryItem(item).count >= amount then
					player.removeInventoryItem(item,amount)
					return true
				else
					return false
				end
			end
		end,

		getInventoryWeight = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.weight
			end
		end,

		getInventoryMaxWeight = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				return player.maxWeight
			end
		end,

		getItemWeight = function(item)
			if item == "" then
				return 0
			end
			if ESX.Items[item] then
				return ESX.Items[item].weight
			end
		end,

		getItemName = function(item)
			if item == "" then
				return ""
			end
			if ESX.Items[item] then
				return ESX.Items[item].label
			end
		end,

		getItemIndex = function(item)
			if item == "" then
				return ""
			end
			if ESX.Items[item] then
				return item
			end
		end,

		giveVehicle = function(user_id,vehicle)
			local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = ?', {user_id})
			local plate = ""
			local HashKey = GetHashKey(vehicle)

			for k,v in pairs(result) do
				if json.decode(v.vehicle).model == HashKey then
					return true
				end
			end

			local eventCallBackName = "striata_resources:tempEvent:N"..math.random( 1,10000 )
			local plate = ""
			RegisterServerEvent(eventCallBackName)
			local event = AddEventHandler(eventCallBackName,function(cb)
				plate = cb
			end)
			TriggerClientEvent("striata_resources:duplicityClientVersion",ESX.GetPlayerFromIdentifier(user_id).playerId,eventCallBackName,"exports",'esx_vehicleshop',"GeneratePlate")
		
			
			while plate == "" do
				Wait(50)
			end
			RemoveEventHandler(event)

			return MySQL.Sync.fetchAll('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking) VALUES (@owner, @plate, @vehicle, @stored, @parking)', {
				['@owner']   = user_id,
				['@plate']   = plate,
				['@vehicle'] = json.encode({model = HashKey, plate = plate}),
				['@stored']  = 1,
				['@parking']  = "SanAndreasAvenue"
			})
		end,

		removeVehicle = function(user_id,vehicle)
			local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = ?', {user_id})
			local plate = ""
			for k,v in pairs(result) do
				if json.decode(v.vehicle).model == GetHashKey(vehicle) then
					plate = v.plate
				end
			end
			
			return MySQL.Sync.fetchAll("DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
				["@owner"] = user_id,
				["@plate"] = plate,
			})
		end,

		saveOutfit = function(source,_outfit)
			local outfit = ""

			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})

			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				outfit = json.decode(savedOutfit)
			else
				savedOutfit = ""
				outfit = _outfit
				MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit",
					["@txt"] = json.encode(outfit)
				})
			end
			
			local rIdle = {}
			for k,v in pairs(outfit) do
				rIdle[k] = v
			end

			return rIdle
		end,

		removeOutfit = function(source)
			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})
			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				savedOutfit = json.decode(savedOutfit)
				savedOutfit.modelhash = nil
				TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",savedOutfit)

				return MySQL.Sync.fetchAll("DELETE FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit"
				})
			end
		end,

		getArrestPoliceTime = function(user_id)
			local timeDB = MySQL.Sync.fetchAll("SELECT jail_time FROM users WHERE identifier = @identifier", {
				["@identifier"] = user_id,
			})
			jailTime = timeDB[1].jail_time
			return json.encode(math.ceil( (jailTime / 60) ))
		end,

		setArrestPoliceTime = function(user_id,time)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				TriggerClientEvent("esx_jail:unjailPlayer",player.playerId)
			end

			return MySQL.Sync.fetchAll("UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier", {
				["@identifier"] = user_id,
				["@jail_time"] = time,
			})
		end,

		getFines = function(user_id)
			return 0
		end,

		setFine = function(user_id,value)
			return Functions["server"].removeBankMoney(user_id,value)
		end,

		getUserInfo = function(user_id)
			local info = {}

			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				info["name"] = player.variables.firstName
				info["lastName"] = player.variables.lastName
				info["age"] = player.variables.dateofbirth
				info["document"] = user_id
				info["phone"] = "000-000"
				return info
			else
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				player = playerInfos[1]
				info["name"] = player.firstname
				info["lastName"] = player.lastname
				info["age"] = player.dateofbirth
				info["document"] = user_id
				info["phone"] = "000-000"
				return info
			end
		end,

		bannedPlayer = function(user_id,toogle)
			if not toogle then
				toogle = true
			end
		end,

		setHunger = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				TriggerClientEvent('esx_status:set', player.playerId, 'hunger', amount*10000)
			end
		end,

		setThirst = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				TriggerClientEvent('esx_status:set', player.playerId, 'thirst', amount*10000)
			end
		end,

		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()

				ESX.RegisterUsableItem(survivalLangs.itens.itemMedBag, function(source)
					TriggerEvent("striata:survival:medBag",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemTweezers, function(source)
					TriggerEvent("striata:survival:useTweezers",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemSutureKit, function(source)
					TriggerEvent("striata:survival:useSutureKit",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemBurnCream, function(source)
					TriggerEvent("striata:survival:useBurnCream",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemDefib, function(source)
					TriggerEvent("striata:survival:useDefib",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemStretcher, function(source)
					TriggerEvent("striata:survival:useStretcher",source)
				end)

				ESX.RegisterUsableItem(survivalLangs.itens.itemShroud, function(source)
					TriggerEvent("striata:survival:shroud",source)
				end)
			end
		end,
	}
}

Events.ESX = {
	client = {
		playerSpawn = "esx:playerLoaded"
	},
	server = {
		playerSpawn = "esx:playerLoaded"
	}
}

Functions.QBCore = {
	client = {
		getSharedObject = function()
			return exports['qb-core']:GetCoreObject()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		request = function(text, time)
			local dialog = exports['qb-input']:ShowInput({
				header = "Confirmação",
				submitText = "Confirmar",
				inputs = {
					{
						text = text,
						name = "requestConfirmation",
						type = "checkbox",
						options = {
							{ value = "confirmed", text = "Sim", checked = true },
						}
					},
				},
			})
		
			return dialog.confirmed
		end,

		textInput = function(text, input)
			local keyboard = exports['qb-input']:ShowInput({
				header = text,
				submitText = "Confirm",
				inputs = {
					{
						text = input,
						name = "cb",
						type = "text",
						isRequired = true,
					},	
				}	
			})
			if keyboard then
				return keyboard.cb
			else
				return ""
			end
		end,	
		
		getOutfit = function()
			local ped = PlayerPedId()
			local custom = {}
			custom.modelhash = GetEntityModel(ped)
		
			for i = 0,20 do
				custom[i] = { GetPedDrawableVariation(ped,i),GetPedTextureVariation(ped,i),GetPedPaletteVariation(ped,i) }
			end
		
			for i = 0,10 do
				custom["p"..i] = { GetPedPropIndex(ped,i),math.max(GetPedPropTextureIndex(ped,i),0) }
			end
			return custom
		end,

		getWeapons = function()
			local player = PlayerPedId()
			local ammo_types = {}
			local weapons = {}
			local weapon_types = { "WEAPON_DAGGER","WEAPON_BAT","WEAPON_BOTTLE","WEAPON_CROWBAR","WEAPON_FLASHLIGHT","WEAPON_GOLFCLUB","WEAPON_HAMMER","WEAPON_HATCHET","WEAPON_KNUCKLE","WEAPON_KNIFE","WEAPON_MACHETE","WEAPON_SWITCHBLADE","WEAPON_NIGHTSTICK","WEAPON_WRENCH","WEAPON_BATTLEAXE","WEAPON_POOLCUE","WEAPON_STONE_HATCHET","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_STUNGUN","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_SNSPISTOL_MK2","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_REVOLVER_MK2","WEAPON_DOUBLEACTION","WEAPON_RAYPISTOL","WEAPON_CERAMICPISTOL","WEAPON_NAVYREVOLVER","WEAPON_GADGETPISTOL","WEAPON_STUNGUN_MP","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_COMBATPDW","WEAPON_MACHINEPISTOL","WEAPON_MINISMG","WEAPON_RAYCARBINE","WEAPON_PUMPSHOTGUN","WEAPON_PUMPSHOTGUN_MK2","WEAPON_SAWNOFFSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_AUTOSHOTGUN","WEAPON_COMBATSHOTGUN","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_SPECIALCARBINE_MK2","WEAPON_BULLPUPRIFLE","WEAPON_BULLPUPRIFLE_MK2","WEAPON_COMPACTRIFLE","WEAPON_MILITARYRIFLE","WEAPON_HEAVYRIFLE","WEAPON_TACTICALRIFLE","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_GUSENBERG","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_MARKSMANRIFLE_MK2","WEAPON_PRECISIONRIFLE","WEAPON_RPG","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_MINIGUN","WEAPON_FIREWORK","WEAPON_RAILGUN","WEAPON_HOMINGLAUNCHER","WEAPON_COMPACTLAUNCHER","WEAPON_RAYMINIGUN","WEAPON_EMPLAUNCHER","WEAPON_GRENADE","WEAPON_BZGAS","WEAPON_MOLOTOV","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_SNOWBALL","WEAPON_PIPEBOMB","WEAPON_BALL","WEAPON_SMOKEGRENADE","WEAPON_FLARE","WEAPON_PETROLCAN","GADGET_PARACHUTER","WEAPON_FIREEXTINGUISHER","WEAPON_HAZARDCAN","WEAPON_FERTILIZERCAN" }
			for k,v in pairs(weapon_types) do
				local hash = GetHashKey(v)
				if HasPedGotWeapon(player,hash) then
					local weapon = {}
					weapons[v] = weapon
					local atype = GetPedAmmoTypeFromWeapon(player,hash)
					if ammo_types[atype] == nil then
						ammo_types[atype] = true
						weapon.ammo = GetAmmoInPedWeapon(player,hash)
					else
						weapon.ammo = 0
					end
				end
			end
		
			return weapons
		end,

		giveWeapons = function(weapons,clearBefore)
			local player = PlayerPedId()
			if clearBefore then
				RemoveAllPedWeapons(player,true)
				weapon_list = {}
			end
		
			for k,weapon in pairs(weapons) do
				local hash = GetHashKey(k)
				local ammo = weapon.ammo or 0
				GiveWeaponToPed(player,hash,ammo,false)
				weapon_list[k] = weapon
			end
		end,

		setOutfit = function(outfit)
			if outfit then
				local ped = PlayerPedId()
				local mhash = nil
				local maxHealt = GetPedMaxHealth(ped)
				
				if outfit.modelhash then
					mhash = outfit.modelhash
				elseif outfit.model then
					mhash = GetHashKey(outfit.model)
				end
	
				if mhash then
					local i = 0
					while not HasModelLoaded(mhash) and i < 10000 do
						RequestModel(mhash)
						Citizen.Wait(10)
					end
	
					if HasModelLoaded(mhash) then
						local weapons = Functions["client"].getWeapons()
						local armour = GetPedArmour(ped)
						local health = GetEntityHealth(ped)
						SetPlayerModel(PlayerId(),mhash)

						ped = PlayerPedId()

						SetPedMaxHealth(ped,maxHealt)
						SetEntityHealth(ped,health)
						Functions["client"].giveWeapons(weapons,true)
						SetPedArmour(ped,armour)
						SetModelAsNoLongerNeeded(mhash)
					end
				end
	
				for k,v in pairs(outfit) do
					if k ~= "model" and k ~= "modelhash" then
						local function parse_part(key)
							if type(key) == "string" and string.sub(key,1,1) == "p" then
								return true,tonumber(string.sub(key,2))
							else
								return false,tonumber(key)
							end
						end

						local isprop, index = parse_part(k)

						if isprop then
							if v[1] < 0 then
								ClearPedProp(ped,index)
							else
								SetPedPropIndex(ped,index,v[1],v[2],v[3] or 2)
							end
						else
							SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
						end							
					end
				end
			end
		end,

		setPlayerHandcuffed = function(toggle)
		   TriggerServerEvent("police:server:SetHandcuffStatus", toggle)
		end,

		teleportPlayer = function(x,y,z)
			TriggerEvent("QBCore:Command:TeleportToCoords",x, y, z)
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		getNearestVehicles = function(radius)
			local vehicles = {}
			local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))
		
			local vehs = {}
			local it,veh = FindFirstVehicle()
			if veh then
				table.insert(vehs,veh)
			end
			local ok
			repeat
				ok,veh = FindNextVehicle(it)
				if ok and veh then
					table.insert(vehs,veh)
				end
			until not ok
			EndFindVehicle(it)
		
			for n,veh in pairs(vehs) do
				local x,y,z = table.unpack(GetEntityCoords(veh))
				local distance = Vdist(x,y,z,px,py,pz)
				if distance <= radius then
					vehicles[veh] = distance
				end
			end
			return vehicles
		end,

		getNearestVehicle = function(radius)
			local vehicle
			local vehicles = Functions["client"].getNearestVehicles(radius)
			local min = radius+0.0001
			for veh,dist in pairs(vehicles) do 
				if dist < min then
					min = dist
					vehicle = veh
				end
			end
			return vehicle
		end,
		
		getNearestPlayers = function(radius)
			local allPlayers = QBCore.Functions.GetPeds()
			local players = {}
			for n,player in pairs(allPlayers) do
				local coords = GetEntityCoords(PlayerPedId())
				local pedCoords = GetEntityCoords(player)
				local distance = #(pedCoords - coords)
				players[GetPlayerServerId(player)] = distance
			end
			return players
		end,

		getNearestPlayer = function(radius)
			local player, distance = QBCore.Functions.GetClosestPlayer()
			if distance <= radius then
				return GetPlayerServerId(player)
			end
			return false
		end,

		killGod = function()
			TransitionFromBlurred(1000)
			nocauteado = false
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			SetEntityHealth(ped,120)
			ClearPedTasks(ped)
			ClearPedSecondaryTask(ped)
		end,
	
		setHealth = function(health)
			return SetEntityHealth(PlayerPedId(),tonumber(health))
		end,

		addBlip = function(x,y,z,idtype,idcolor,text,scale,route)
			local blip = AddBlipForCoord(x,y,z)
			SetBlipSprite(blip,idtype)
			SetBlipAsShortRange(blip,true)
			SetBlipColour(blip,idcolor)
			SetBlipScale(blip,scale)

			if route then
				SetBlipRoute(blip,true)
			end

			if text then
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(text)
				EndTextCommandSetBlipName(blip)
			end
			return blip
		end,

		removeBlip = function(blipId)
			RemoveBlip(id)
		end,
	},

	server = {

		getSharedObject = function()
			return exports['qb-core']:GetCoreObject()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserId = function(source)
			local player = QBCore.Functions.GetPlayer(source)
			if player then
				return player.PlayerData.citizenid
			end
		end,

		getUserSource = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.PlayerData.source
			end
		end,

		getUsers = function()
			local users = {}
			for k,v in pairs(QBCore.Functions.GetPlayers()) do
				users[(QBCore.Functions.GetPlayer(v)).PlayerData.citizenid] = v
			end
			return users
		end,

		getUsersByPermission = function(perm)
			local users = {}
			for k,v in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(v))
				if Functions["server"].hasPermission(user_id,perm) then
					table.insert(users,user_id)
				end
			end
			return users
		end,

		hasPermission = function(user_id,perm)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				if QBCore.Functions.GetPlayer(player.PlayerData.source).PlayerData.job.name == perm or QBCore.Functions.HasPermission(player.PlayerData.source, perm) then
					return true
				else
					return false
				end
			else
				return false
			end
		end,

		getUserGroups = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				local groups = QBCore.Functions.GetPlayer(player.PlayerData.source).PlayerData.job
				local usergroups = {}
				for k,v in pairs(groups) do
					if k == "name" then
						usergroups[v] = true
					end
				end
				return usergroups
			else
				return false
			end
		end,
		
		addUserGroup = function(user_id,group)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.SetJob(group, 1)
			else
				return false
			end
		end,

		removeUserGroup = function(user_id,group)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.SetJob("unemployed", '0')
			else
				local job = {}
				job.name = "unemployed"
				job.label = "Unemployed"
				job.payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500
				job.onduty = true
				job.isboss = false
				job.grade = {}
				job.grade.name = nil
				job.grade.level = 0
				return MySQL.Sync.fetchAll('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), user_id })
			end
		end,

		giveHandMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.AddMoney('cash', tonumber(amount))
			else
				return false
			end
		end,

		removeHandMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.RemoveMoney('cash', amount)
			else
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = ?', { user_id })
				local playerMoney = json.decode(data[1].money)
				local cashCount = tonumber(playerMoney.cash) - tonumber(amount)
				if cashCount > 0  then
					local newPlayerMoney = json.encode({cash = cashCount, crypto = tonumber(playerMoney.crypto), bank = tonumber(playerMoney.bank)})
					MySQL.Sync.fetchAll('UPDATE players SET money = ? WHERE citizenid = ?', {newPlayerMoney, user_id})
					return true
				else
					return false
				end
			end
		end,

		giveBankMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.AddMoney('bank', tonumber(amount), "Bank depost")
			else
				return false
			end
		end,

		removeBankMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.RemoveMoney('bank', amount, "Bank depost")
			else
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = ?', { user_id })
				local playerBank = json.decode(data[1].money)
				local bankCount = tonumber(playerBank.bank) - tonumber(amount)
				if bankCount > 0  then
					local newPlayerBank = json.encode({cash = tonumber(playerBank.cash), crypto = tonumber(playerBank.crypto), bank = bankCount})
					MySQL.Sync.fetchAll('UPDATE players SET money = ? WHERE citizenid = ?', {newPlayerBank, user_id})
					return true
				else
					return false
				end
			end
		end,

		getInventoryItemAmount = function(user_id,item)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				local itemInfo = player.Functions.GetItemByName(item)
				local itemAmount = 0
				if itemInfo then
					itemAmount = itemInfo.amount
				end
				return itemAmount
			else
				return false
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.AddItem(item,amount)
			else
				return false
			end
		end,

		removeInventoryItem = function(user_id,item,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return player.Functions.RemoveItem(item,amount)
			else
				return false
			end
		end,

		getInventoryWeight = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return exports['qb-inventory']:GetTotalWeight(player.PlayerData.items)
			else
				return false
			end
		end,

		getInventoryMaxWeight = function(user_id)
			return 120000
		end,

		getItemWeight = function(item)
			if item == "" then
				return ""
			end
			return QBCore.Shared.Items[item].weight
		end,

		getItemName = function(item)
			if item == "" then
				return ""
			end
			return QBCore.Shared.Items[item].label
		end,

		getItemIndex = function(item)
			if item == "" then
				return ""
			end
			local index = QBCore.Shared.Items[item].image
			index = index:gsub("%.png", "")
			return index
		end,

		giveVehicle = function(user_id,vehicle)
			local plate
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				repeat
					plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
					local result = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
					Wait(1)
				until(#result <= 0)
				plate = plate:upper()
				
				return MySQL.Sync.fetchAll('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
					player.PlayerData.license,
					player.PlayerData.citizenid,
					vehicle,
					GetHashKey(vehicle),
					'{}',
					plate,
					'pillboxgarage',
					1
				})
			end
		end,

		removeVehicle = function(user_id,vehicle)
			return MySQL.Sync.fetchAll("DELETE FROM player_vehicles WHERE citizenid = @citizenid AND vehicle = @vehicle", {
				["@citizenid"] = user_id,
				["@vehicle"] = vehicle,
			})
		end,

		saveOutfit = function(source,_outfit)
			local outfit = ""

			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})

			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				outfit = json.decode(savedOutfit)
			else
				savedOutfit = ""
				outfit = _outfit
				MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit",
					["@txt"] = json.encode(outfit)
				})
			end
			
			local rIdle = {}
			for k,v in pairs(outfit) do
				rIdle[k] = v
			end

			return rIdle
		end,

		removeOutfit = function(source)
			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})
			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				savedOutfit = json.decode(savedOutfit)
				savedOutfit.modelhash = nil
				TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",savedOutfit)

				return MySQL.Sync.fetchAll("DELETE FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit"
				})
			end
		end,

		getArrestPoliceTime = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
			   return player.PlayerData.metadata["injail"]
			else
				return MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = Functions["server"].getUserId(source),
				}).injail
			end
		end,

		setArrestPoliceTime = function(user_id,time)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				player.Functions.SetMetaData('injail', time)

				local _hasRecord = false
				if time > 0 then
					_hasRecord = true
				end
				player.Functions.SetMetaData('criminalrecord', {hasRecord = _hasRecord})
			else
				local infosDB = MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				local metadata = json.decode(infosDB[1].metadata)
				
				metadata.injail = time
				local _hasRecord = false
				if time > 0 then
					_hasRecord = true
				end
				metadata.criminalrecord = {hasRecord = _hasRecord}
				return MySQL.Sync.fetchAll("UPDATE players SET metadata = @metadata WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
			end
		end,

		getFines = function(user_id)
			return 0
		end,

		setFine = function(user_id,value)
			return Functions["server"].removeBankMoney(user_id,value)
		end,

		getUserInfo = function(user_id)
			local info = {}

			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				player = player.PlayerData
				info["name"] = player.charinfo.firstname
				info["lastName"] = player.charinfo.lastname
				info["age"] = player.charinfo.birthdate
				info["document"] = user_id
				info["phone"] = player.charinfo.phone
				return info
			else
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				player = json.decode(playerInfos[1].charinfo)
				info["name"] = player.firstname
				info["lastName"] = player.lastname
				info["age"] = player.birthdate
				info["document"] = user_id
				info["phone"] = player.phone
				return info
			end
		end,

		bannedPlayer = function(user_id,toogle)
			if not toogle then
				toogle = true
			end
			
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)

			if player then
				player = player.PlayerData
				local source = player.source
				return MySQL.Sync.fetchAll('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name,@license,@discord,@ip,@reason,@expire,@bannedby)', {
					["@name"] = player.charinfo.firstname.." "..player.charinfo.lastname,
					["@license"] = QBCore.Functions.GetIdentifier(source, 'license'),
					["@discord"] = QBCore.Functions.GetIdentifier(source, 'discord'),
					["@ip"] = QBCore.Functions.GetIdentifier(source, 'ip'),
					["@reason"] = "striata resources ban",
					["@expire"] = 4102444800,
					["@bannedby"] = 'striata_resources'
				})
			else
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				return MySQL.Sync.fetchAll('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name,@license,@discord,@ip,@reason,@expire,@bannedby)', {
					["@name"] =  json.decode(playerInfos[1].charinfo).firstname.." "..json.decode(playerInfos[1].charinfo).lastname,
					["@license"] = playerInfos[1].license,
					["@discord"] = "",
					["@ip"] = "",
					["@reason"] = "striata resources ban",
					["@expire"] = 4102444800,
					["@bannedby"] = 'striata_resources'
				})
			end
		end,

		setHunger = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				player.Functions.SetMetaData('hunger', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, amount, player.PlayerData.metadata.thirst)
			end
		end,

		setThirst = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				player.Functions.SetMetaData('thirst', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, player.PlayerData.metadata.hunger, amount)
			end
		end,

		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemMedBag, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:medBag",source)
					end
				end)

				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemTweezers, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:useTweezers",source)
					end
				end)
				
				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemSutureKit, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:useSutureKit",source)
					end
				end)

				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemBurnCream, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:useBurnCream",source)
					end
				end)

				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemDefib, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:useDefib",source)
					end
				end)

				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemStretcher, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:useStretcher",source)
					end
				end)

				QBCore.Functions.CreateUseableItem(survivalLangs.itens.itemShroud, function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerEvent("striata:survival:shroud",source)
					end
				end)
			end
		end,
	}
}

Events.QBCore = {
	client = {
		playerSpawn = "QBCore:Client:OnPlayerLoaded"
	},
	server = {
		playerSpawn = "QBCore:Server:OnPlayerLoaded"
	}
}

Functions.custom = {
	client = {
		getSharedObject = function()
			return nil
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getOutfit = function()
			return nil
		end,

		setOutfit = function(outfit)
			return nil
		end,

		setPlayerHandcuffed = function(toggle)
			return nil
		end,

		teleportPlayer = function(x,y,z)
			return nil
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		getNearestVehicles = function(radius)
			return nil
		end,

		getNearestVehicle = function(radius)
			return nil
		end,
		
		getNearestPlayer = function(radius)
			return nil
		end,

		killGod = function()
			return nil
		end,
	
		setHealth = function(health)
			return nil
		end,

		addBlip = function(x,y,z,idtype,idcolor,text,scale,route)
			local blip = AddBlipForCoord(x,y,z)
			SetBlipSprite(blip,idtype)
			SetBlipAsShortRange(blip,true)
			SetBlipColour(blip,idcolor)
			SetBlipScale(blip,scale)

			if route then
				SetBlipRoute(blip,true)
			end

			if text then
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(text)
				EndTextCommandSetBlipName(blip)
			end
			return blip
		end,

		removeBlip = function(blipId)
			RemoveBlip(id)
		end,
	},

	server = {
		getSharedObject = function()
			return nil
		end,

		exports = function(...)
			local args = {...}
			return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
		end,

		getUserId = function(source)
			return nil
		end,

		getUserSource = function(user_id)
			return nil
		end,

		getUsers = function()
			return nil
		end,

		getUsersByPermission = function(perm)
			return nil
		end,

		hasPermission = function(user_id, perm)
			return nil
		end,

		getUserGroups = function(user_id)
			return nil
		end,

		getAllUserGroups = function()
			local allUserGroups = {}
			return allUserGroups
		end,

		addUserGroup = function(user_id,group)
			return nil
		end,

		removeUserGroup = function(user_id,group)
			return nil
		end,

		request = function(source, text, time)	  
			return nil
		end,

		textInput = function(source,text, input)
			return nil
		end,

		giveHandMoney = function(user_id, amount)
			return nil
		end,

		removeHandMoney = function(user_id, amount)
			return nil
		end,

		giveBankMoney = function(user_id, amount)
			return nil
		end,

		removeBankMoney = function(user_id, amount)
			return nil
		end,

		getInventoryItems = function(user_id,item)
			local itemsTable = {}
			return itemsTable
		end,

		getInventoryItemAmount = function(user_id,item)
			return nil
		end,

		giveInventoryItem = function(user_id,item,amount)
			return nil
		end,

		removeInventoryItem = function(user_id,item,amount)
			return nil
		end,

		getInventoryWeight = function(user_id)
			return nil
		end,

		getInventoryMaxWeight = function(user_id)
			return nil
		end,

		getItemWeight = function(item)
			return nil
		end,

		getItemName = function(item)
			return nil
		end,

		getItemIndex = function(item)
			return nil
		end,

		giveVehicle = function(user_id,vehicle)
			return nil
		end,

		removeVehicle = function(user_id,vehicle)
			return nil
		end,

		saveOutfit = function(source,outfit)
			return nil
		end,

		removeOutfit = function(source)
			return nil
		end,

		getArrestPoliceTime = function(user_id)
			return nil
		end,

		setArrestPoliceTime = function(user_id,time)
			return nil
		end,

		getFines = function(user_id)
			return nil
		end,

		setFine = function(user_id,value)
			return nil
		end,

		getUserInfo = function(user_id)
			return nil
		end,

		bannedPlayer = function(user_id,toogle)
			return nil
		end,

		setHealth = function(user_id,amount)
			return nil
		end,

		setArmour = function(user_id,amount)
			return nil
		end,

		setHunger = function(user_id,amount)
			return nil
		end,

		setThirst = function(user_id,amount)
			return nil
		end,

		setStress = function(user_id,amount)
			return nil
		end,
		
		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			return false
		end,

		getWhiteListStatus = function(user_id,status)
			return nil
		end,

		changeWhiteListStatus = function(user_id,status)
			return nil
		end,

		getBanStatus = function(user_id)
			return nil
		end,

		setBanStatus = function(user_id,status,reason)
			return nil
		end
	}
	
}

Events.custom = {
	client = {
		playerSpawn = ""
	},
	server = {
		playerSpawn = ""
	}
}