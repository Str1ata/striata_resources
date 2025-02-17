FunctionsVersion = 1.71  --! por favor não altere aqui! | please do not change here!
FunctionsAutoUpdate = true --? Ative\Desative as atualizações automáticas aqui! | Enable/Disable automatic updates here!
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

		request = function(text, time)
			local source = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
			return getTunnelInformation("request","functions",source,text,time)
		end,

		textInput = function(text, input)
			local source = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
			return getTunnelInformation("textInput","functions",source,text,input)
		end,

		getWeapons = function()
			if vRP.getWeapons then
				return vRP.getWeapons()
			else
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
			end
		end,

		giveWeapons = function(weapons,clearBefore)
			if vRP.giveWeapons then
				return vRP.giveWeapons(weapons,clearBefore)
			else
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
				
				return true
			end
		end,

		getOutfit = function()
			if vRP.getCustomization then
				return vRP.getCustomization()
			else
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
			end
		end,

		setOutfit = function(outfit)
			if vRP.setCustomization then
				return vRP.setCustomization(outfit)
			else
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
			end
		end,

		setPlayerHandcuffed = function(toggle)
			if vRP.setHandcuffed then
				vRP.setHandcuffed(toggle)
				return true
			elseif LocalPlayer["state"]["Handcuff"] ~= nil then
				LocalPlayer["state"]["Handcuff"] = toggle
				return true
			end

			return false
		end,

		teleportPlayer = function(x,y,z)
			if vRP.teleport then
				vRP.teleport(x,y,z)
			else
				SetEntityCoords(PlayerPedId(), vector3(x,y,z), false, false, false, false)
			end
			return true
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		getNearestVehicles = function(radius)
			if vRP.getNearestVehicles then 
				return vRP.getNearestVehicles(radius)
			else
				local r = {}
				local coords = GetEntityCoords(PlayerPedId())
			
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
			
				for _,veh in pairs(vehs) do
					local coordsVeh = GetEntityCoords(veh)
					local distance = #(coords - coordsVeh)
					if distance <= radius then
						r[veh] = distance
					end
				end
				return r
			end
		end,

		getNearestVehicle = function(radius)
			if vRP.getNearestVehicle then 
				return vRP.getNearestVehicle(radius)
			elseif vRP.nearVehicle then 
				return vRP.nearVehicle(radius)
			elseif vRP.ClosestVehicle then 
				return vRP.ClosestVehicle(radius)
			else
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
			end
		end,
		
		getNearestPlayers = function(radius)
			if vRP.getNearestPlayers then
				return vRP.getNearestPlayers(radius)
			elseif vRP.ClosestPeds then
				return vRP.ClosestPeds(radius)
			else
				local allPlayers = GetActivePlayers()
				local players = {}
				local currentPedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
				for n,playerId in pairs(allPlayers) do
					if GetPlayerServerId(playerId) ~= currentPedId then
						local player = GetPlayerPed(playerId)
						local coords = GetEntityCoords(PlayerPedId())
						local pedCoords = GetEntityCoords(player)
						local distance = #(pedCoords - coords)
						players[GetPlayerServerId(playerId)] = distance
					end
				end
				return players
			end
		end,

		getNearestPlayer = function(radius)
			if vRP.getNearestPlayer then
				return vRP.getNearestPlayer(radius)
			elseif vRP.ClosestPed then
				return vRP.ClosestPed(radius)
			else	
				for player, distance in pairs (Functions["client"]:getNearestPlayers(radius)) do
					if distance <= radius then
						return player
					end
				end
				return false
			end
		end,

		killGod = function()
			if vRP.killGod then
				return vRP.killGod()
			else
				TransitionFromBlurred(1000)

				local ped = PlayerPedId()
				if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
					local x,y,z = table.unpack(GetEntityCoords(ped))
					NetworkResurrectLocalPlayer(x,y,z,true,true,false)
				end
				ClearPedBloodDamage(ped)
				SetEntityInvincible(ped,false)
				Functions["client"].setHealth(120)
				ClearPedTasks(ped)
				ClearPedSecondaryTask(ped)
				return true
			end
		end,
	
		setHealth = function(health)
			if vRP.setHealth then
				vRP.setHealth(health)
				return true
			else
				SetEntityHealth(PlayerPedId(),tonumber(health))
				return true
			end
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

		AddTargetModel = function(models,configuration)
			if GetResourceState('target') == "started" then
				exports["target"]:AddTargetModel(models,{
					options = configuration.options,
					distance = configuration.distance,
					Distance = configuration.distance
				})

				return true
			end
		end
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

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end
			if vRP.getUserIdByIdentifiers then
				return vRP.getUserIdByIdentifiers(identifiers)
			else
				local steam

				for n,identifier in pairs(identifiers) do
					if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
						steam = identifier
						break
					end
				end
	
				return steam
			end
		end,
		
		getUserId = function(source)
			return (vRP.getUserId and vRP.getUserId(source)) or (vRP.Passport and vRP.Passport(source)) or (nil)
		end,

		getUserSource = function(user_id)
			return (vRP.getUserSource and vRP.getUserSource(parseInt(user_id))) or (vRP.userSource and vRP.userSource(parseInt(user_id))) or (vRP.Source and vRP.Source(parseInt(user_id))) or (nil)
		end,

		getUsers = function()
			if vRP.getUsers then
				return vRP.getUsers()
			elseif vRP.userList then
				return vRP.userList()
			elseif vRP.Players then
				return vRP.Players()
			else
				local users = {}
				for k,v in pairs(GetPlayers()) do
					local user_id = Functions["server"].getUserId(tonumber(v))
					users[user_id] = v
				end
				return users
			end
		end,

		getUsersByPermission = function(perm)
			local users = {}
			if vRP.getUsersByPermission then
				return vRP.getUsersByPermission(perm)
			elseif vRP.numPermission then
				local usersInService = vRP.numPermission(perm)
				for user_id,source in pairs(GetPlayers()) do
					table.insert(users,user_id)
				end
				return users
			elseif vRP.NumPermission then
				local usersInService = vRP.NumPermission(perm)
				for user_id,source in pairs(GetPlayers()) do
					table.insert(users,user_id)
				end
				return users
			else
				for n,source in pairs(GetPlayers()) do
					local user_id = Functions["server"].getUserId(tonumber(source))
					if Functions["server"].hasPermission(user_id,perm) then
						table.insert(users,user_id)
					end
				end
				return users
			end
		end,

		hasPermission = function(user_id, perm)
			return (vRP.hasPermission and vRP.hasPermission(parseInt(user_id), perm)) or (vRP.HasPermission and vRP.HasPermission(parseInt(user_id), perm)) or (false)
		end,

		getUserGroups = function(user_id)
			local userGroupsFormat = {}
			
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				if vRP.getUserGroups then
					local userGroups = vRP.getUserGroups(parseInt(user_id))
					for group,status in pairs(userGroups) do
						if status then
							userGroupsFormat[group] = { hierarchyName = "" }
						end
					end
				elseif vRP.Groups then
					for group, infos in pairs(vRP.Groups()) do
						local Data = vRP.DataGroups(group)
						if Data[tostring(user_id)] then
							userGroupsFormat[group] = { hierarchyName = infos.Hierarchy[Data[tostring(user_id)]] }
						end
					end
				end
				return userGroupsFormat
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data') AS t_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_vrp_user_data_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)

				if resultCheck[1].t_vrp_user_data_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_data_exists > 0 and resultCheck[1].c_dkey_inT_vrp_user_data_exists > 0 then
					--? Zirix
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
				elseif resultCheck[1].t_entitydata_exists > 0 then
					--? Creative network
					local allGroups = vRP.Groups()

					local rows = MySQL.Sync.fetchAll("SELECT * FROM entitydata")
	
					if #rows > 0 then
						local dkeySearch = "Permissions:"
						for n,rowInfos in pairs(rows) do
							local dkeyString = rowInfos.dkey or rowInfos.Name
							if string.find(dkeyString,dkeySearch) then
								local usersInPermissionList = rowInfos.dvalue and json.decode(rowInfos.dvalue) or rowInfos.Information or json.encode(rowInfos.Information)
								local group = dkeyString:sub(#dkeySearch + 1)
								for Passport, Hierarchy in pairs(usersInPermissionList) do 
									if tonumber(Passport) == user_id then
										userGroupsFormat[group] = { hierarchyName = (allGroups[group] and allGroups[group].Hierarchy and allGroups[group].Hierarchy[Hierarchy]) or Hierarchy }
										break
									end
								end
							end
						end
					end
				end

				return userGroupsFormat
			end
		end,

		getAllUserGroups = function()
			local allUserGroups = {}
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data') AS t_vrp_user_data_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_vrp_user_data_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dvalue') AS c_dvalue_inT_vrp_user_data_exists,
					
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_vrp_user_data_exists > 0 and resultCheck[1].c_dkey_inT_vrp_user_data_exists > 0 and resultCheck[1].c_dvalue_inT_vrp_user_data_exists > 0 then
				--? Zirix
				local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_data WHERE dkey = @dkey",{
					['@dkey'] = "vRP:datatable"
				})
				if #rows > 0 then
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
				end
			elseif resultCheck[1].t_entitydata_exists > 0 then
				--? Creative network
				local allGroups = vRP.Groups()

				local rows = MySQL.Sync.fetchAll("SELECT * FROM entitydata")
				if #rows > 0 then
					local dkeySearch = "Permissions:"
					for rowNumber,rowInfos in pairs(rows) do
						local dkeyString = rowInfos.dkey or rowInfos.Name
						if string.find(dkeyString,dkeySearch) then
							local usersInPermissionList = rowInfos.dvalue and json.decode(rowInfos.dvalue) or rowInfos.Information or json.encode(rowInfos.Information)
							local group = dkeyString:sub(#dkeySearch + 1)

							if not allUserGroups[group] then
								allUserGroups[group] = {}
							end
							
							for Passport, Hierarchy in pairs(usersInPermissionList) do
								table.insert( allUserGroups[group], { user_id = tonumber(Passport), hierarchyName = (allGroups[group] and allGroups[group].Hierarchy and allGroups[group].Hierarchy[Hierarchy]) or Hierarchy } )
							end
						end
					end
				end
			end

			return allUserGroups
		end,

		addUserGroup = function(user_id,group)
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				return (vRP.addUserGroup and vRP.addUserGroup(parseInt(user_id),group)) or (vRP.SetPermission and vRP.SetPermission(parseInt(user_id),group)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data') AS t_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dvalue') AS c_dvalue_inT_vrp_user_data_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
	
				if resultCheck[1].t_vrp_user_data_exists > 0 and resultCheck[1].c_dkey_inT_vrp_user_data_exists > 0 and resultCheck[1].c_dvalue_inT_vrp_user_data_exists > 0 then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					if dataTable and dataTable.groups then
						if not dataTable.groups[group] then
							dataTable.groups[group] = true
							return vRP._setUData(user_id, "vRP:datatable", json.encode(dataTable))
						end
					end
				elseif resultCheck[1].t_entitydata_exists > 0 then
					--? Creative network
					local allGroups = vRP.Groups()

					local rows = MySQL.Sync.fetchAll("SELECT * FROM entitydata")
					if #rows > 0 then
						local dkeySearch = "Permissions:"
						local groupTableFind = false
						for rowNumber,rowInfos in pairs(rows) do
							local dkeyString = rowInfos.dkey or rowInfos.Name
							if string.find(dkeyString,dkeySearch) then
								local usersInPermissionList = rowInfos.dvalue and json.decode(rowInfos.dvalue) or rowInfos.Information or json.encode(rowInfos.Information)
								local _group = dkeyString:sub(#dkeySearch + 1)
	
								if group == _group then
									groupTableFind = usersInPermissionList
									
									groupTableFind[tostring(user_id)] = #allGroups[group].Hierarchy
									break
								end
							end
						end

						local queryCheck2 = [[
							SELECT 
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists,
								
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_entitydata_exists,
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'dvalue') AS c_dvalue_inT_entitydata_exists,
								
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'Name') AS c_Name_inT_entitydata_exists,
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'Information') AS c_Information_inT_entitydata_exists
						]]
						local resultCheck2 = MySQL.Sync.fetchAll(queryCheck2)

						if resultCheck2[1].c_dkey_inT_entitydata_exists > 0 and resultCheck2[1].c_dvalue_inT_entitydata_exists > 0 then						
							MySQL.Sync.fetchAll("REPLACE INTO entitydata(dkey,dvalue) VALUES(@dkey,@dvalue)", {
								["@dkey"] = dkeySearch..group,
								["@dvalue"] = groupTableFind or { [tostring(user_id)] = #allGroups[group].Hierarchy }
							})
						elseif resultCheck2[1].c_Name_inT_entitydata_exists > 0 and resultCheck2[1].c_Information_inT_entitydata_exists > 0 then
							MySQL.Sync.fetchAll("REPLACE INTO entitydata(Name,Information) VALUES(@Name,@Information)", {
								["@Name"] = dkeySearch..group,
								["@Information"] = groupTableFind or { [tostring(user_id)] = #allGroups[group].Hierarchy }
							})
						end

						return true
					end
				end
			end
		end,

		removeUserGroup = function(user_id,group)
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				return (vRP.removeUserGroup and vRP.removeUserGroup(parseInt(user_id),group)) or (vRP.RemovePermissionand and vRP.RemovePermissionand(parseInt(user_id),group)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data') AS t_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_vrp_user_data_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_data' AND COLUMN_NAME = 'dvalue') AS c_dvalue_inT_vrp_user_data_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
	
				if resultCheck[1].t_vrp_user_data_exists > 0 and resultCheck[1].c_dkey_inT_vrp_user_data_exists > 0 and resultCheck[1].c_dvalue_inT_vrp_user_data_exists > 0 then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					if dataTable and dataTable.groups then
						if dataTable.groups[group] then
							dataTable.groups[group] = nil
							return vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
						end
					end
				elseif resultCheck[1].t_entitydata_exists > 0 then
					--? Creative network
					local allGroups = vRP.Groups()

					local rows = MySQL.Sync.fetchAll("SELECT * FROM entitydata")
					if #rows > 0 then
						local dkeySearch = "Permissions:"
						local groupTableFind = false
						for rowNumber,rowInfos in pairs(rows) do
							local dkeyString = rowInfos.dkey or rowInfos.Name
							if string.find(dkeyString,dkeySearch) then
								local usersInPermissionList = rowInfos.dvalue and json.decode(rowInfos.dvalue) or rowInfos.Information or json.encode(rowInfos.Information)
								local _group = dkeyString:sub(#dkeySearch + 1)
	
								if group == _group then
									groupTableFind = usersInPermissionList
									
									if groupTableFind[tostring(user_id)] then
										groupTableFind[tostring(user_id)] = nil
									else
										groupTableFind = false
									end
									break
								end
							end
						end

						local queryCheck2 = [[
							SELECT 
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata') AS t_entitydata_exists,
								
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'dkey') AS c_dkey_inT_entitydata_exists,
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'dvalue') AS c_dvalue_inT_entitydata_exists,
								
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'Name') AS c_Name_inT_entitydata_exists,
								(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'entitydata' AND COLUMN_NAME = 'Information') AS c_Information_inT_entitydata_exists
						]]
						local resultCheck2 = MySQL.Sync.fetchAll(queryCheck2)

						if groupTableFind then
							if resultCheck2[1].c_dkey_inT_entitydata_exists > 0 and resultCheck2[1].c_dvalue_inT_entitydata_exists > 0 then						
								MySQL.Sync.fetchAll("REPLACE INTO entitydata(dkey,dvalue) VALUES(@dkey,@dvalue)", {
									["@dkey"] = dkeySearch..group,
									["@dvalue"] = groupTableFind
								})
							elseif resultCheck2[1].c_Name_inT_entitydata_exists > 0 and resultCheck2[1].c_Information_inT_entitydata_exists > 0 then
								MySQL.Sync.fetchAll("REPLACE INTO entitydata(Name,Information) VALUES(@Name,@Information)", {
									["@Name"] = dkeySearch..group,
									["@Information"] = groupTableFind
								})
							end

							return true
						else
							return false
						end
					end
				end
			end
		end,

		request = function(source, text, time)
			if vRP.request then
				return vRP.request(source, text, time)
			elseif vRP.Request then
				return vRP.Request(source,text,"Sim","Não")
			end
		end,

		textInput = function(source,text, input)
			vKEYBOARD = Tunnel.getInterface("keyboard")
			if vRP.prompt then
				local resp = vRP.prompt(source,text, input)
				return resp
			elseif vKEYBOARD.keySingle ~= nil then
				local text = vKEYBOARD.keySingle(source,text,input)
	
				if not text then
					text = ""
				else
					text = text[1]
				end

				return text
			elseif vKEYBOARD.Primary ~= nil then
				local text = vKEYBOARD.Primary(source,text)
	
				if not text then
					text = ""
				else
					text = text[1]
				end

				return text
			end
		end,

		giveHandMoney = function(user_id, amount)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.giveMoney and vRP.giveMoney(parseInt(user_id),amount)) or (vRP.giveInventoryItem and vRP.giveInventoryItem(user_id,"dinheiro",amount,true)) or (vRP.GenerateItem and vRP.GenerateItem(user_id,"dinheiro",amount,true)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'wallet') AS c_wallet_inT_vrp_user_moneys_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
	
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_wallet_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE vrp_user_moneys SET wallet = @wallet WHERE user_id = @user_id", {
							["@user_id"] = parseInt(user_id),
							["@wallet"] = tonumber(rows[1].wallet) + amount,
						})
						
						return true
					else
						return false
					end
				elseif vRP.UserData then
					--? Creative network
					return Function["server"].getInventoryItemAmount(user_id,"dinheiro",amount)
				end
			end
		end,

		removeHandMoney = function(user_id, amount)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.tryPayment and vRP.tryPayment(parseInt(user_id),amount)) or (vRP.tryGetInventoryItem and vRP.tryGetInventoryItem(user_id,"dinheiro",amount,true)) or (vRP.TakeItem and vRP.TakeItem(user_id,"dinheiro",amount,true)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'wallet') AS c_wallet_inT_vrp_user_moneys_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_wallet_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE vrp_user_moneys SET wallet = @wallet WHERE user_id = @user_id", {
							["@user_id"] = parseInt(user_id),
							["@wallet"] = tonumber(rows[1].wallet) - amount,
						})
						
						return true
					else
						return false
					end
				elseif vRP.UserData then
					--? Creative network
					return Function["server"].removeInventoryItem(user_id,"dinheiro",amount)
				end
			end
		end,

		getHandMoney = function(user_id)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.getMoney and vRP.getMoney(parseInt(user_id))) or (vRP.getInventoryItemAmount and vRP.getInventoryItemAmount(user_id,"dinheiro")) or (vRP.ItemAmount and vRP.ItemAmount(user_id,"dinheiro")) or (vRP.InventoryItemAmount and vRP.InventoryItemAmount(user_id,"dinheiro")[1]) or 0
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'wallet') AS c_wallet_inT_vrp_user_moneys_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_wallet_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})
	
					if rows[1] then
						return tonumber(rows[1].wallet)
					else
						return 0
					end
				elseif vRP.UserData then
					--? Creative network
					return Function["server"].getInventoryItemAmount(user_id,"dinheiro")
				end
			end
		end,

		giveBankMoney = function(user_id, amount)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.giveBankMoney and vRP.giveBankMoney(parseInt(user_id),amount)) or (vRP.addBank and vRP.addBank(parseInt(user_id),amount)) or (vRP.GiveBank and vRP.GiveBank(parseInt(user_id),amount)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'bank') AS c_bank_inT_vrp_user_moneys_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters') AS t_characters_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'id') AS c_id_inT_characters_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'bank') AS c_bank_inT_characters_exists,
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
	
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_bank_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE vrp_user_moneys SET bank = @bank WHERE user_id = @user_id", {
							["@user_id"] = parseInt(user_id),
							["@bank"] = tonumber(rows[1].bank) + amount,
						})
						
						return true
					else
						return false
					end
				elseif resultCheck[1].t_characters_exists > 0 and resultCheck[1].c_id_inT_characters_exists > 0 and resultCheck[1].c_bank_inT_characters_exists > 0 then
					--? Creative network
					local rows = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE id = @passport", {
						["@passport"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE characters SET bank = @bank WHERE id = @passport", {
							["@passport"] = parseInt(user_id),
							["@bank"] = tonumber(rows[1].bank) + amount,
						})
						
						return true
					else
						return false
					end
				end
			end
		end,

		removeBankMoney = function(user_id, amount)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.tryWithdraw and vRP.tryWithdraw(parseInt(user_id),amount)) or (vRP.delBank and vRP.delBank(parseInt(user_id),amount)) or (vRP.RemoveBank and vRP.RemoveBank(parseInt(user_id),amount)) or (vRP.tryFullPayment and vRP.tryFullPayment(parseInt(user_id),amount)) or (vRP.PaymentFull and vRP.PaymentFull(parseInt(user_id),amount)) or (false)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'bank') AS c_bank_inT_vrp_user_moneys_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters') AS t_characters_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'id') AS c_id_inT_characters_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'bank') AS c_bank_inT_characters_exists,
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_bank_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE vrp_user_moneys SET bank = @bank WHERE user_id = @user_id", {
							["@user_id"] = parseInt(user_id),
							["@bank"] = tonumber(rows[1].bank) - amount,
						})
						
						return true
					else
						return false
					end
				elseif resultCheck[1].t_characters_exists > 0 and resultCheck[1].c_id_inT_characters_exists > 0 and resultCheck[1].c_bank_inT_characters_exists > 0 then
					--? Creative network
					local rows = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE id = @passport", {
						["@passport"] = user_id
					})

					if rows[1] then
						MySQL.Sync.fetchAll("UPDATE characters SET bank = @bank WHERE id = @passport", {
							["@passport"] = parseInt(user_id),
							["@bank"] = tonumber(rows[1].bank) - amount,
						})
						
						return true
					else
						return false
					end
				end
			end
		end,

		getBankMoney = function(user_id)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				return (vRP.getBankMoney and vRP.getBankMoney(parseInt(user_id))) or (vRP.getBank and vRP.getBank(parseInt(user_id))) or (vRP.GetBank and vRP.GetBank(Functions["server"].getUserSource(user_id))) or (0)
			else
				--? Player Offline
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys') AS t_vrp_user_moneys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_moneys_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_moneys' AND COLUMN_NAME = 'bank') AS c_bank_inT_vrp_user_moneys_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters') AS t_characters_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'id') AS c_id_inT_characters_exists
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'bank') AS c_bank_inT_characters_exists,
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
				if resultCheck[1].t_vrp_user_moneys_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_moneys_exists > 0 and resultCheck[1].c_bank_inT_vrp_user_moneys_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @user_id", {
						["@user_id"] = user_id
					})

					if rows[1] then
						return tonumber(rows[1].bank)
					else
						return 0
					end
				elseif resultCheck[1].t_characters_exists > 0 and resultCheck[1].c_id_inT_characters_exists > 0 and resultCheck[1].c_bank_inT_characters_exists > 0 then
					--? Creative network
					local rows = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE id = @passport", {
						["@passport"] = user_id
					})
	
					if rows[1] then
						return tonumber(rows[1].bank)
					else
						return 0
					end
				end
			end
		end,

		getInventoryItems = function(user_id)
			local itemsTable = {}

			local inventory = {}

			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online

				if vRP.Inventory then
					currentInventory = vRP.Inventory(user_id) or {}
					for slot,itensIfos in pairs(currentInventory) do
						inventory[itensIfos.item] = {amount = itensIfos.amount}
					end
				else
					inventory = (vRP.getInventory and vRP.getInventory(parseInt(user_id))) or (vRP.getUserDataTable and vRP.getUserDataTable(parseInt(user_id)).inventory) or ({})
				end
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					if Datatable and Datatable.Inventory then
						for slot, itemInfos in pairs(Datatable.Inventory) do
							inventory[itensIfos.item] = {amount = itensIfos.amount}
						end
					end
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					inventory = dataTable and dataTable.inventory or {}
				end
			end

			for item, amountTable in pairs(inventory) do
				itemsTable[item] = amountTable.amount
			end

			return itemsTable
		end,

		getInventoryItemAmount = function(user_id,item)
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				return (vRP.getInventoryItemAmount and vRP.getInventoryItemAmount(parseInt(user_id),item)) or (vRP.ItemAmount and vRP.ItemAmount(parseInt(user_id),item)) or (vRP.InventoryItemAmount and vRP.InventoryItemAmount(parseInt(user_id),item)[1]) or (0)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					if Datatable and Datatable.Inventory then
						for slot, itemInfos in pairs(Datatable.Inventory) do
							if itemInfos.item == item then
								return itemInfos.amount
							end
						end
					end

					return 0
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					inventory = dataTable.inventory
					if inventory[item] then
						return inventory[item].amount
					else
						return 0
					end
				end
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				return (vRP.giveInventoryItem and vRP.giveInventoryItem(parseInt(user_id),item,amount,true)) or (vRP.GiveItem and vRP.GiveItem(parseInt(user_id),item,amount,true)) or (vRP.GenerateItem and vRP.GenerateItem(parseInt(user_id),item,amount,true)) or (false)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					local finded = false
					if Datatable and Datatable.Inventory then
						for slot, itemInfos in pairs(Datatable.Inventory) do
							if itemInfos.item == item then
								Datatable.Inventory[slot].amount = (tonumber(itemInfos.amount) + amount)
								finded = true
								break
							end
						end
					end

					if finded then
						vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
						return true
					else
						if not Datatable.Inventory then
							Datatable.inventory = {}
						end
						Datatable.inventory[#Datatable.inventory + 1] = {item = item, amount = amount}

						vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
						return true
					end

					return false
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					inventory = dataTable.inventory or {}
					if inventory[item] then
						inventory[item].amount = inventory[item].amount + amount
					else
						inventory[item] = {amount = amount}
					end
				end

				dataTable.inventory = inventory
				vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))

				return true
			end

			return false
		end,

		removeInventoryItem = function(user_id,item,amount)
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				if vRP.tryGetInventoryItem then
					return vRP.tryGetInventoryItem(parseInt(user_id),item,amount,true)
				elseif vRP.InventoryItemAmount and vRP.TakeItem then
					consultItem = vRP.InventoryItemAmount(user_id,item)
					if not consultItem then
						return false
					else
						if consultItem[2] then
							return vRP.TakeItem(user_id,consultItem[2],amount,true)
						else
							return false
						end
					end					
				else
					return false
				end
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					local finded = false
					if Datatable and Datatable.Inventory then
						for slot, itemInfos in pairs(Datatable.Inventory) do
							if itemInfos.item == item then
								if Datatable.Inventory[slot].amount < amount then
									return false
								else
									Datatable.Inventory[slot].amount = (tonumber(itemInfos.amount) - amount)

									finded = true
									break
								end
							end
						end
					end

					if finded then
						vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
						return true
					end

					return false
				elseif vRP.getUData then
					--? Zirix
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
			end
		end,

		getInventoryWeight = function(user_id)
			return (vRP.getInventoryWeight and vRP.getInventoryWeight(parseInt(user_id))) or (vRP.inventoryWeight and vRP.inventoryWeight(parseInt(user_id))) or (vRP.InventoryWeight and vRP.InventoryWeight(parseInt(user_id))) or (0.0)
		end,

		getInventoryMaxWeight = function(user_id)
			return (vRP.getInventoryMaxWeight and vRP.getInventoryMaxWeight(parseInt(user_id))) or (vRP.getWeight and vRP.getWeight(parseInt(user_id))) or (vRP.GetWeight and vRP.GetWeight(parseInt(user_id))) or (0.0)
		end,

		getItemWeight = function(item)
			return (vRP.getItemWeight and vRP.getItemWeight(item)) or (itemWeight and itemWeight(item)) or (0.0)
		end,

		getItemName = function(item)
			return (vRP.itemNameList and vRP.itemNameList(item)) or (itemName and itemName(item)) or ("")
		end,

		getItemIndex = function(item)
			return (vRP.itemIndexList and vRP.itemIndexList(item)) or (itemIndex and itemIndex(item)) or ("")
		end,

		giveVehicle = function(user_id,vehicle)
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles') AS t_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'vehicle') AS c_vehicle_inT_vrp_user_vehicles_exists
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'ipva') AS c_ipva_inT_vrp_user_vehicles_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_vrp_user_vehicles_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_vehicles_exists > 0 and resultCheck[1].c_vehicle_inT_vrp_user_vehicles_exists > 0 and resultCheck[1].c_ipva_inT_vrp_user_vehicles_exists > 0 then
				MySQL.Sync.fetchAll("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)", {
					["@user_id"] = user_id,
					["@vehicle"] = vehicle,
					["@ipva"] = parseInt(os.time())
				})
			elseif vRP.Query and vRP.GeneratePlate then
				return vRP.Query("vehicles/addVehicles",{ Passport = user_id, vehicle = vehicle, plate = vRP.GeneratePlate(), work = "false" })
			else
				return false
			end
		end,

		removeVehicle = function(user_id,vehicle)
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles') AS t_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'vehicle') AS c_vehicle_inT_vrp_user_vehicles_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)
			
			if resultCheck[1].t_vrp_user_vehicles_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_vehicles_exists > 0 and resultCheck[1].c_vehicle_inT_vrp_user_vehicles_exists > 0 then
				MySQL.Sync.fetchAll("DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle", {
					["@user_id"] = user_id,
					["@vehicle"] = vehicle
				})
			elseif vRP.Query then
				return vRP.Query("vehicles/removeVehicles",{ Passport = user_id, vehicle = vehicle })
			else
				return false
			end
		end,
		
		getUserVehicles = function(user_id)
			local vehiclesInfos = {}

			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles') AS t_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_vehicles_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_vehicles' AND COLUMN_NAME = 'vehicle') AS c_vehicle_inT_vrp_user_vehicles_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_vrp_user_vehicles_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_vehicles_exists > 0 and resultCheck[1].c_vehicle_inT_vrp_user_vehicles_exists > 0 then
				--? Zirix
				local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id", {
					["@user_id"] = user_id
				})

				if #rows >= 1 then
					for n,vehicleInfo in pairs(rows) do
						table.insert(vehiclesInfos,
							{
								model = vehicleInfo.vehicle,
								plate = "",
								arest = vehicleInfo.detido, 
								engineHealth = vehicleInfo.enigne, 
								bodyHealth = vehicleInfo.body,
								fuel = vehicleInfo.fuel,
								taxTime = vehicleInfo.ipva,
								odometer = vehicleInfo.odometer,
								tunning = {},
								damage = json.decode(vehicleInfo.estado)
							}
						)
					end
				end
			elseif vRP.Query then
				--? Creative network
				local Consult = vRP.Query("vehicles/UserVehicles", { Passport = user_id })
				for _, v in pairs(Consult) do
					if VehicleExist(v["vehicle"]) then
						if v["work"] == "false" then
							table.insert(vehiclesInfos,
								{
									model = v.vehicle,
									plate = v.plate,
									arest = v.arrest,
									engineHealth = v.engine,
									bodyHealth = v.body,
									fuel = v.fuel,
									taxTime = v.tax,
									odometer = 0,
									tunning =  {},
									damage = {}
								}
							)
						end
					end
				end
			end

			return vehiclesInfos
		end,

		saveOutfit = function(source,outfit)
			if vRP.save_idle_custom then
				return vRP.save_idle_custom(source,outfit)
			else
				local currentOutfit = ""

				local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = (Functions["server"].getUserId(source)),
					["@db"] = "beforePrisonOutfit"
				})

				if #savedOutfit > 0 then
					savedOutfit = savedOutfit[1].txt
					currentOutfit = json.decode(savedOutfit)
				else
					savedOutfit = ""
					currentOutfit = outfit
					MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
						["@user_id"] = Functions["server"].getUserId(source),
						["@db"] = "beforePrisonOutfit",
						["@txt"] = json.encode(outfit)
					})
				end
				
				local rIdle = {}
				for k,v in pairs(currentOutfit) do
					rIdle[k] = v
				end

				return rIdle
			end
		end,

		removeOutfit = function(source)
			if vRP.removeCloak then
				return vRP.removeCloak(source)
			else
				local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = (Functions["server"].getUserId(source)),
					["@db"] = "beforePrisonOutfit"
				})
				if #savedOutfit > 0 then
					savedOutfit = json.decode(savedOutfit[1].txt) or {}
					savedOutfit.modelhash = nil
					TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",savedOutfit)

					MySQL.Sync.fetchAll("DELETE FROM striatadb WHERE user_id = @user_id AND db = @db", {
						["@user_id"] = Functions["server"].getUserId(source),
						["@db"] = "beforePrisonOutfit"
					})
					return true
				end
			end
		end,

		getArrestPoliceTime = function(user_id)
			if vRP.getUData then
				--? Zirix
				return vRP.getUData(parseInt(user_id),"vRP:prisao")
			else
				--? Creative network
				local Query = vRP.Query("characters/Person", { id = user_id })
				if #Query > 0 then
					return Query[1].prison
				else
					return 0
				end
			end
		end,

		setArrestPoliceTime = function(user_id,time)
			return (vRP.InitPrison and vRP.InitPrison(user_id, time)) or (vRP.setUData and vRP.setUData(parseInt(user_id),"vRP:prisao",json.encode(parseInt(time)))) or (false)
		end,

		getFines = function(user_id)
			return (vRP.getFines and vRP.getFines(parseInt(user_id))) or (vRP.GetFine and vRP.GetFine(parseInt(user_id))) or (vRP.getUData and vRP.getUData(parseInt(user_id),"vRP:multas")) or (0.0)
		end,

		setFine = function(user_id,value)
			return (vRP.addFines and vRP.addFines(parseInt(user_id))) or (vRP.GiveFine and vRP.GiveFine(parseInt(user_id),value)) or (vRP.setUData and vRP.setUData(parseInt(user_id),"vRP:multas",json.encode(parseInt(value)))) or (false)
		end,

		getUserInfo = function(user_id)
			local info = {}
			if Functions["server"].getUserSource(parseInt(user_id)) then
				--? Player Online
				local identity = (vRP.getUserIdentity and vRP.getUserIdentity(parseInt(user_id))) or (vRP.Identity and vRP.Identity(Passport))
				info["name"] = identity.name or identity.Name
				info["lastName"] = identity.firstname or identity.name2 or identity.Lastname
				info["age"] = identity.age or 20
				info["document"] = identity.registration or identity.license
				info["phone"] = identity.phone
				return info
			else
				--? Player Offline
				local identity

				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_identities') AS t_vrp_user_identities_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_user_identities' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_identities_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters') AS t_characters_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'id') AS c_id_inT_characters_exists,
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
	
				if resultCheck[1].t_vrp_user_identities_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_identities_exists > 0 then
					--? Zirix
					local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_identities WHERE user_id = @user_id", {
						["@user_id"] = user_id,
					})
					identity = playerInfos[1]
				elseif resultCheck[1].t_characters_exists > 0 and resultCheck[1].c_id_inT_characters_exists > 0 then
					--? Creative network
					local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE id = @id", {
						["@id"] = user_id,
					})
					identity = playerInfos[1]
				end
				
				info["name"] = identity.name or identity.Name
				info["lastName"] = identity.firstname or identity.name2 or identity.Lastname
				info["age"] = identity.age or 20
				info["document"] = identity.registration or identity.license
				info["phone"] = identity.phone
				return info
			end
		end,

		getHealth = function(user_id)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRPclient.getHealth and vRPclient.getHealth(source)) or (vRP.GetHealth and vRP.GetHealth(source)) or nil
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					return Datatable.Health
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					return dataTable.health
				end
			end
		end,

		setHealth = function(user_id,amount)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRPclient.setHealth and vRPclient.setHealth(source,amount)) or (vRPclient.SetHealth and vRPclient.SetHealth(source,amount)) or (false)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					Datatable.Health = amount
					vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
					return true
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					dataTable.health = amount
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				end
				return false
			end
		end,

		getArmour = function(user_id)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRPclient.getArmour and vRPclient.getArmour(source)) or GetPedArmour(GetPlayerPed(source))
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					return dataTable.Armour
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					return dataTable.colete
				end
			end
		end,

		setArmour = function(user_id,amount)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRPclient.setArmour(source,amount)) or (vRP.SetArmour(source,amount)) or (false)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					Datatable.Armour = amount
					vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
					return true
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					dataTable.colete = amount
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				end
				return false
			end
		end,

		getHunger = function(user_id)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRP.getHunger and vRP.getHunger(parseInt(user_id))) or (vRP.Datatable and vRP.Datatable(parseInt(user_id)).Hunger) or (100.0)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					return dataTable.Hunger
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					return dataTable.hunger
				end
			end
		end,

		setHunger = function(user_id,amount)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				if vRP.setHunger then
					return vRP.setHunger(parseInt(user_id),amount)
				elseif vRP.UpgradeHunger then
					local currentHunger = Functions["server"].getHunger(user_id) 
					return vRP.UpgradeHunger(parseInt(user_id),amount - currentHunger)
				end
				return false
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					Datatable.Hunger = amount
					vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
					return true
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					dataTable.hunger = amount
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				end
				return false
			end
		end,

		getThirst = function(user_id)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRP.getThirst and vRP.getThirst(parseInt(user_id))) or (vRP.Datatable and vRP.Datatable(parseInt(user_id)).Thirst) or (100.0)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					return Datatable.Thirst
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					return dataTable.thirst
				end
			end
		end,

		setThirst = function(user_id,amount)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				if vRP.setThirst then
					return vRP.setThirst(parseInt(user_id),amount)
				elseif vRP.UpgradeThirst then
					local currentThirst = Functions["server"].getThirst(user_id) 
					return vRP.UpgradeThirst(parseInt(user_id),amount - currentThirst)
				end
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					Datatable.Thirst = amount
					vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
					return true
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					dataTable.thirst = amount
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				end
				return false
			end
		end,

		getStress = function(user_id)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				return (vRP.getStress and vRP.getStress(parseInt(user_id))) or (vRP.Datatable and vRP.Datatable(parseInt(user_id)).Stress) or (0.0)
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					return Datatable.Stress
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					return dataTable.stress
				end
			end
		end,

		setStress = function(user_id,amount)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if source then
				--? Player Online
				if vRP.setStress then
					return vRP.setStress(parseInt(user_id),amount)
				elseif vRP.UpgradeStress then
					local currentStress = Functions["server"].getStress(user_id) 
					return vRP.UpgradeStress(parseInt(user_id),amount - currentStress)
				end
			else
				--? Player Offline
				if vRP.UserData then
					--? Creative network
					local Datatable = vRP.UserData(user_id,"Datatable")
					Datatable.Stress = amount
					vRP.Query("playerdata/SetData",{ Passport = user_id, Name = "Datatable", dkey = "Datatable", dvalue = json.encode(Datatable), Information = json.encode(Datatable)})
					return true
				elseif vRP.getUData then
					--? Zirix
					local dataTable = json.decode(vRP.getUData(parseInt(user_id), "vRP:datatable") or {})
					dataTable.stress = amount
					vRP._setUData(parseInt(user_id), "vRP:datatable", json.encode(dataTable))
					return true
				end
				return false
			end
		end,
		
		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
			end

			if Config.resources["striata_advancedfuel"] then
				local advancedFuelConfig, advancedFuelLangs = exports['striata_resources']:striata_advancedFuel_config()

				-- "galao-gasoline" --? fivem
				-- "galao-diesel" --? fivem
				-- "galao-gas" --? fivem
				-- "galao-ethanol" --? fivem
				-- "galao-avGas" --? fivem
				-- "bateria" --? fivem / redm
				-- "sacocomcarvao" --? redm
				-- "balde-animalfeed" --? redm
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			if user_id and homeName	then
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_homes_permissions') AS t_vrp_user_vehicles_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vrp_homes_permissions' AND COLUMN_NAME = 'user_id') AS c_user_id_inT_vrp_user_vehicles_exists,
						
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'propertys') AS t_propertys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'propertys' AND COLUMN_NAME = 'Name') AS c_Name_inT_propertys_exists,
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'propertys' AND COLUMN_NAME = 'Passport') AS c_Passport_inT_propertys_exists,
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)

				if resultCheck[1].t_vrp_user_vehicles_exists > 0 and resultCheck[1].c_user_id_inT_vrp_user_vehicles_exists > 0 then
					--? Zirix
					local rows = MySQL.Sync.fetchAll("SELECT * FROM vrp_homes_permissions WHERE user_id = @user_id", {
						["@user_id"] = user_id,
					})
					if rows and #rows > 0 then
						for rowNumber, rowInfos in pairs(rows) do 
							if rowInfos.home == homeName then
								return true
							end
						end
					end
				elseif resultCheck[1].t_propertys_exists > 0 and resultCheck[1].c_Name_inT_propertys_exists > 0 and resultCheck[1].c_Passport_inT_propertys_exists > 0 then
					--? Creative network
					local rows = MySQL.Sync.fetchAll("SELECT * FROM propertys WHERE Passport = @Passport", {
						["@Passport"] = user_id,
					})
					if rows and #rows > 0 then
						for rowNumber, rowInfos in pairs(rows) do 
							if rowInfos.Name == homeName then
								return true
							end
						end
					end
				end
				
				TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
				return false
			end
		end,

		getWhiteListStatus = function(user_id)
			if vRP.isWhitelisted then
				return vRP.isWhitelisted(parseInt(user_id))
			elseif vRP.Identities and vRP.Account then
				local Identity = vRP.Identities(source)
				local Account = vRP.Account(Identity)
				return Account.whitelist
			end
		end,

		changeWhiteListStatus = function(user_id,status)
			if vRP.setWhitelisted then
				return vRP.setWhitelisted(parseInt(user_id),status)
			elseif vRP.Query then
				vRP.Query("accounts/updateWhitelist",{ id = parseInt(user_id), whitelist = status })
				return
			end
		end,

		getBanStatus = function(user_id)
			if vRP.isBanned then
				return (vRP.isBanned and vRP.isBanned(parseInt(user_id))) or (false)
			elseif vRP.Banned and vRP.Identity then
				return (vRP.Banned and vRP.Banned(vRP.Identity(user_id).License)) or (false)
			end
		end,

		setBanStatus = function(user_id,status,reason)
			local source = Functions["server"].getUserSource(parseInt(user_id))
			if status and source then
				DropPlayer(source, reason)
			end

			if vRP.setBanned then
				return (vRP.setBanned(parseInt(user_id),status)) or (false)
			elseif vRP.Query and vRP.Identity then
				return (vRP.Query("banneds/InsertBanned",{ license = vRP.Identity(user_id).License, time = 0 })) or (false)
			end
		end,

		checkPlayerIsDiscordMember = function(user_id,discordId)
			if Config.resources["striata_discordbot"] then
				return exports["striata_resources"]:checkIsMember(user_id,discordId)
			else
				return false
			end
		end
	}
	
}
Events.vRP = {
	client = {
		playerSpawn = "tvRP:playerSpawnNow",
		groupChange = {"vRP:GroupUpdated"}
	},
	server = {
		playerSpawn = "vRP:playerSpawn",
		groupChange = {"vRP:GroupUpdated","vRP:PlayerJoinGroup","vRP:PlayerLeaveGroup"}
	}
}
if IsDuplicityVersion() then --? Server only
	RegisterServerEvent("striata_resources:serverReady")
	AddEventHandler("striata_resources:serverReady",function()
		if CurrentFrameWork == "vRP" then
			for n,event in pairs(Events["server"].groupChange) do
				RegisterServerEvent(event)
				AddEventHandler(event, function(user_id,group)
					local source = Functions["server"].GetUserSource(user_id)
					TriggerClientEvent("vRP:GroupUpdated",source,group)
				end)
			end
		end
	end)
end

Functions.ESX = {
	client = {
		getSharedObject = function()
			return exports['es_extended']:getSharedObject()
		end,
		
		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		request = function(text, time)
			local elements = {
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
			exports["esx_context"]:Open("right", elements, function(menu, element)
		
				if element.value == "yes" then
					exports["esx_context"]:Close()
					resp = true
				end
				if element.value == "no" then
					exports["esx_context"]:Close()
					resp = false
				end
			end,function()
				if resp == "" then
					resp = false
				end
			end)

			local timeout = false
			SetTimeout(1000*time,function()
				timeout = true
			end)
			repeat
				Wait(50)
			until(resp ~= "" or timeout)

			if timeout then
				exports["esx_context"]:Close()
			end

			return resp
		end,

		textInput = function(text, input)
			local elements = {
				{
					icon = "",  -- disable icon
					title = text, -- Title of number input to show to user
					input = true, -- allow input
					inputType = "text", -- allow numbers to be inputted
					inputPlaceholder = input, -- PlaceHolder value
					inputValue = input, -- default value
				},
				{
					icon = "fas fa-check",
					title = "Enviar",
					name = "submit",
				},
			}

			local resp = ""
			exports["esx_context"]:Open("right", elements, function(menu, element)
				if element.name == "submit" then	
					resp = menu.eles[1].inputValue
					exports["esx_context"]:Close()
				else
					resp = false
				end
			end,function()
				if resp == "" then
					resp = false
				end
			end)

			local timeout = false
			SetTimeout(1000*60*10,function()
				timeout = true
			end)
			repeat
				Wait(50)
			until(resp ~= "" or timeout)

			if timeout then
				exports["esx_context"]:Close()
			end

			return resp or ""

			-- local keyboard, cb = exports["nh-keyboard"]:Keyboard({header = text, rows = {input}})
			-- return cb
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
			local allPlayers = GetActivePlayers()
			local players = {}
			local currentPedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
			for n,playerId in pairs(allPlayers) do
				if GetPlayerServerId(playerId) ~= currentPedId then
					local player = GetPlayerPed(playerId)
					local coords = GetEntityCoords(PlayerPedId())
					local pedCoords = GetEntityCoords(player)
					local distance = #(pedCoords - coords)
					players[GetPlayerServerId(playerId)] = distance
				end
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
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			Functions["client"].setHealth(120)
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

		AddTargetModel = function(models,configuration)
			return false
		end
	},

	server = {
		getSharedObject = function()
			return exports['es_extended']:getSharedObject()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end

			local steam

			for n,identifier in pairs(identifiers) do
				if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
					steam = identifier
					break
				end
			end

			return steam
		end,

		getUserId = function(source)
			local player = ESX.GetPlayerFromId(source)
			if player then
				return player.identifier
			end
		end,

		getUserSource = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			return player and player.playerId
		end,

		getUsers = function()
			local users = {}
			for k,v in pairs(ESX.GetPlayers()) do
				local user = ESX.GetPlayerFromId(v)
				if user then
					users[user.identifier] = v
				end
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
				--? Player Online
				return ESX.GetPlayerFromId(player.playerId).job
			else
				--? Player Offline
				local userGroups = {}

				local rows = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
					['@identifier'] = user_id
				})

				if rows[1] then
					userGroupsFormat[rows[1].group] = { hierarchyName = "" }
					userGroupsFormat[rows[1].job] = { hierarchyName = rows[1].job_grade }
				end

				return userGroupsFormat
			end
		end,

		getAllUserGroups = function()
			local allUserGroups = {}
			local rows = MySQL.Sync.fetchAll("SELECT * FROM users ")

			for n, infos in pairs(rows) do
				if not userGroupsFormat[infos.group] then
					userGroupsFormat[infos.group] = {}
				end
				
				if not userGroupsFormat[infos.job] then
					userGroupsFormat[infos.job] = {}
				end
				
				table.insert( allUserGroups[infos.group], { user_id = user_id, hierarchyName = "" } )
				table.insert( allUserGroups[infos.job], { user_id = user_id, hierarchyName = infos.job_grade } )
			end

			return allUserGroups
		end,
		
		addUserGroup = function(user_id,group)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.setGroup(group)
			else
				--? Player Offline
				return MySQL.Sync.fetchAll('UPDATE users SET group = ? WHERE identifier = ?', {job, user_id})
			end
		end,

		removeUserGroup = function(user_id,group)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.setJob("unemployed", 0)
			else
				--? Player Offline
				return MySQL.Sync.fetchAll('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, 0, user_id})
			end
		end,
		
		giveHandMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.addAccountMoney("money",amount)
			else
				--? Player Offline
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
				--? Player Online
				if Functions["server"].getHandMoney(user_id) >= amount then
					player.removeAccountMoney('money', amount)
					return true
				else
					return false
				end
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				if userAccounts.money >= amount then
					userAccounts.money = userAccounts.money - amount
					MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
						["@identifier"] = user_id,
						["@accounts"] = json.encode(userAccounts),
					})
					return true
				else
					return false
				end
			end
		end,

		getHandMoney = function(user_id)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				local player = ESX.GetPlayerFromIdentifier(user_id)
				return player.getAccount("money").money
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				return userAccounts.money
			end
		end,

		giveBankMoney = function(user_id, amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.addAccountMoney("bank",amount)
			else
				--? Player Offline
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
				--? Player Online
				if Functions["server"].getBankMoney(user_id) >= amount then
					player.removeAccountMoney('bank', amount)
					return true
				else
					return false
				end
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)
				
				if userAccounts.bank >= amount then
					userAccounts.bank = userAccounts.bank - amount
					MySQL.Sync.fetchAll("UPDATE users SET accounts = @accounts WHERE identifier = @identifier", {
						["@identifier"] = user_id,
						["@accounts"] = json.encode(userAccounts),
					})
					return true
				else
					return false
				end 
			end
		end,

		getBankMoney = function(user_id)
			if Functions["server"].getUserSource(user_id) then
				--? Player Online
				local player = ESX.GetPlayerFromIdentifier(user_id)
				return player.getAccount("bank").money
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				userAccounts = json.decode(userInfo[1].accounts)

				return userAccounts.bank
			end
		end,

		getInventoryItems = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.getInventory(true)
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT inventory FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})

				return userInfo[1] and json.decode(userInfo[1].inventory) or {}
			end
		end,

		getInventoryItemAmount = function(user_id,item)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				if player.getInventoryItem(item) then
					return player.getInventoryItem(item).count
				else
					return 0
				end
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT inventory FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})

				local userInventory = userInfo[1] and json.decode(userInfo[1].inventory) or {}
				
				return userInventory[item] or 0
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.addInventoryItem(item,amount)
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT inventory FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})

				local inventory = userInfo[1] and json.decode(userInfo[1].inventory) or {}
				
				if inventory[item] then
					inventory[item] = inventory[item] + amount
				else
					inventory[item] = amount
				end
				
				return MySQL.Sync.fetchAll("UPDATE users SET inventory = @inventory WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@inventory"] = json.encode(inventory),
				})
			end
		end,

		removeInventoryItem = function(user_id,item,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				if player.getInventoryItem(item).count >= amount then
					player.removeInventoryItem(item,amount)
					return true
				else
					return false
				end
			else
				--? Player Offline
				local userInfo = MySQL.Sync.fetchAll("SELECT inventory FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})

				local inventory = userInfo[1] and json.decode(userInfo[1].inventory) or {}
				
				if inventory[item] and inventory[item] >= amount then
					inventory[item] = inventory[item] - amount

					if inventory[item] <= 0 then
						inventory[item] = nil
					end

					return MySQL.Sync.fetchAll("UPDATE users SET inventory = @inventory WHERE identifier = @identifier", {
						["@identifier"] = user_id,
						["@inventory"] = json.encode(inventory),
					})
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

			local plate = getTunnelInformation(ESX.GetPlayerFromIdentifier(user_id).playerId,"exports","functions",'esx_vehicleshop',"GeneratePlate")

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

		getUserVehicles = function(user_id)
			local vehiclesInfos = {}

			local rows = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @user_id", {
				["@user_id"] = user_id
			})

			if #rows >= 1 then
				for n,vehicleInfo in pairs(rows) do
					table.insert(vehiclesInfos,
						{
							model = json.decode(v.vehicle).model,
							plate = vehicleInfo.plate,
							arest = false, 
							engineHealth = 100, 
							bodyHealth = 100,
							fuel = 100,
							taxTime = 0,
							odometer = 0,
							tunning = {},
							damage = {}
						}
					)
				end
			end

			return vehiclesInfos
		end,

		saveOutfit = function(source,outfit)
			local currentOutfit = ""

			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})

			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				currentOutfit = json.decode(savedOutfit)
			else
				savedOutfit = ""
				currentOutfit = outfit
				MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit",
					["@txt"] = json.encode(outfit)
				})
			end
			
			local rIdle = {}
			for k,v in pairs(currentOutfit) do
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
				savedOutfit = json.decode(savedOutfit[1].txt) or {}
				savedOutfit.modelhash = nil
				TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",savedOutfit)

				return MySQL.Sync.fetchAll("DELETE FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit"
				})
			end
		end,

		getArrestPoliceTime = function(user_id)
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users') AS t_users_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'jail_time') AS c_users_inT_jail_time_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_users_exists > 0 and resultCheck[1].c_users_inT_jail_time_exists > 0 then
				local timeDB = MySQL.Sync.fetchAll("SELECT jail_time FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				jailTime = timeDB[1].jail_time
			else
				jailTime = 0
			end
			return json.encode(math.ceil( (jailTime / 60) ))
		end,

		setArrestPoliceTime = function(user_id,time)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player and time <= 0 then
				TriggerClientEvent("esx_jail:unjailPlayer",player.playerId)
			end

			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users') AS t_users_exists,
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'jail_time') AS c_users_inT_jail_time_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_users_exists > 0 and resultCheck[1].c_users_inT_jail_time_exists > 0 then
				return MySQL.Sync.fetchAll("UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@jail_time"] = time,
				})
			else
				return false
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

			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				info["name"] = player.variables.firstName
				info["lastName"] = player.variables.lastName
				info["age"] = player.variables.dateofbirth
				info["document"] = user_id
				info["phone"] = "000-000"
				return info
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				player = playerInfos[1]
				info["name"] = player.firstname
				info["lastName"] = player.lastname
				info["age"] = player.dateofbirth
				info["document"] = user_id
				info["phone"] = player.phone_number or "000-000"
				return info
			end
		end,

		getHealth = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.metadata.health
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT metadata FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				player = playerInfos[1]
				return playerInfos[1] and tonumber(json.encode(playerInfos[1].metadata).health)
			end
		end,

		setHealth = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				local ped = GetPlayerPed(player.source)
				xPlayer.setMeta("health", GetEntityHealth(ped))
				return true
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT metadata FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local metadata = playerInfos[1] and json.encode(playerInfos[1].metadata) or {}
				metadata.health = amount
				
				MySQL.Sync.fetchAll("UPDATE users SET metadata = @metadata WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
				
				return true
			end
		end,

		getArmour = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return player.metadata.armor
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT metadata FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				player = playerInfos[1]
				return playerInfos[1] and tonumber(json.encode(playerInfos[1].metadata).armor)
			end
		end,

		setArmour = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				local ped = GetPlayerPed(player.source)
				xPlayer.setMeta("armor", GetPedArmour(ped))
				return true
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT metadata FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local metadata = playerInfos[1] and json.encode(playerInfos[1].metadata) or {}
				metadata.armor = amount
				
				MySQL.Sync.fetchAll("UPDATE users SET metadata = @metadata WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@metadata"] = json.encode(metadata),
				})

				return true
			end
		end,

		getHunger = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				local hunger = 0.0
				TriggerEvent('esx_status:getStatus', target, 'hunger', function(status)
					if status then
						hunger = ESX.Math.Round(status.percent)
					end
				end)

				return hunger
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT status FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local statusTable = playerInfos[1] and json.encode(playerInfos[1].status) or {}

				for n, infos in pairs(statusTable) do
					if infos.name == "hunger" then
						return tonumber(infos.percent)
					end
				end

				return 0.0
			end
		end,

		setHunger = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				TriggerClientEvent('esx_status:set', player.playerId, 'hunger', amount*10000)
				return true
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT status FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local statusTable = playerInfos[1] and json.encode(playerInfos[1].status) or {}

				for n, infos in pairs(statusTable) do
					if infos.name == "hunger" then
						statusTable[n].percent = amount
						statusTable[n].val = amount*10000
						break
					end
				end

				MySQL.Sync.fetchAll("UPDATE users SET status = @status WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@status"] = json.encode(statusTable),
				})

				return true
			end
		end,

		getThirst = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				local thirst = 0.0
				TriggerEvent('esx_status:getStatus', target, 'thirst', function(status)
					if status then
						thirst = ESX.Math.Round(status.percent)
					end
				end)

				return thirst
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT status FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local statusTable = playerInfos[1] and json.encode(playerInfos[1].status) or {}

				for n, infos in pairs(statusTable) do
					if infos.name == "thirst" then
						return tonumber(infos.percent)
					end
				end

				return 0.0
			end
		end,

		setThirst = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				TriggerClientEvent('esx_status:set', player.playerId, 'thirst', amount*10000)
				return true
			else
				--? Player Offline
				local playerInfos = MySQL.Sync.fetchAll("SELECT status FROM users WHERE identifier = @identifier", {
					["@identifier"] = user_id,
				})
				
				local statusTable = playerInfos[1] and json.encode(playerInfos[1].status) or {}

				for n, infos in pairs(statusTable) do
					if infos.name == "thirst" then
						statusTable[n].percent = amount
						statusTable[n].val = amount*10000
						break
					end
				end

				MySQL.Sync.fetchAll("UPDATE users SET status = @status WHERE identifier = @identifier", {
					["@identifier"] = user_id,
					["@status"] = json.encode(statusTable),
				})

				return true
			end
		end,

		getStress = function(user_id)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return 0.0
			else
				--? Player Offline
				return 0.0
			end
		end,

		setStress = function(user_id,amount)
			local player = ESX.GetPlayerFromIdentifier(user_id)
			if player then
				--? Player Online
				return false
			else
				--? Player Offline
				return false
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

			if Config.resources["striata_advancedfuel"] then
				local advancedFuelConfig, advancedFuelLangs = exports['striata_resources']:striata_advancedFuel_config()
				
				ESX.RegisterUsableItem("galao-gasoline", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"gallon","gasoline")
				end)

				ESX.RegisterUsableItem("galao-diesel", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"gallon","diesel")
				end)

				ESX.RegisterUsableItem("galao-gas", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"gallon","gas")
				end)

				ESX.RegisterUsableItem("galao-ethanol", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"gallon","ethanol")
				end)

				ESX.RegisterUsableItem("galao-avGas", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"gallon","avGas")
				end)

				ESX.RegisterUsableItem("bateria", function(source)
					TriggerClientEvent("striata:fuel:refuel",source,"battery","energy")
				end)

				-- ESX.RegisterUsableItem("sacocomcarvao", function(source)
				-- 	TriggerClientEvent("striata:fuel:refuel",source,"gallon","coal")	
				-- end)

				-- ESX.RegisterUsableItem("balde-animalfeed", function(source)
				-- 	TriggerClientEvent("striata:fuel:refuel",source,"gallon","animalfeed")	
				-- end)
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			local propertiesList = exports["esx_property"]:GetProperties()
			for propertyId, infos in pairs(propertiesList) do
				if infos.Name == homeName then
					if infos.Owned and infos.Owner == user_id then
						return true
					elseif infos.Keys[user_id] then
						return true
					end
				end
			end

			TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
			return false
		end,

		getWhiteListStatus = function(user_id)
			return true
		end,

		changeWhiteListStatus = function(user_id,status)
			return false
		end,

		getBanStatus = function(user_id)
			return false
		end,

		setBanStatus = function(user_id,toogle,reason)
			if not toogle then
				toogle = true
			end
		end,

		checkPlayerIsDiscordMember = function(user_id,discordId)
			if Config.resources["striata_discordbot"] then
				return exports["striata_resources"]:checkIsMember(user_id,discordId)
			else
				return false
			end
		end
	}
}
Events.ESX = {
	client = {
		playerSpawn = "esx:playerLoaded",
		groupChange = {"esx:setJob","esx:setGroup"}
	},
	server = {
		playerSpawn = "esx:playerLoaded",
		groupChange = {"esx:setJob","esx:setGroup"}
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
		
			if not dialog or dialog.confirmed == "false" then
				dialog.confirmed = false
			elseif dialog.confirmed == "true" then
				dialog.confirmed = true
			end

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
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			Functions["client"].setHealth(120)
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

		AddTargetModel = function(models,configuration)
			if GetResourceState('qb-target') == "started" then
				local newOptions = {}
				for n,option in pairs(configuration.options) do
					newOptions[n] = {
						event = option.event,
						label = option.label,
						type = option.tunnel,
					}
				end
				
				exports['qb-target']:RemoveTargetModel(models)
	
				exports['qb-target']:AddTargetModel(models,{
					options = newOptions,
					distance = configuration.distance
				})

				return true
			end
		end
	},

	server = {

		getSharedObject = function()
			return exports['qb-core']:GetCoreObject()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end

			local steam

			for n,identifier in pairs(identifiers) do
				if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
					steam = identifier
					break
				end
			end

			return steam
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
				end
			end

			return false
		end,

		getUserGroups = function(user_id)
			local userGroupsFormat = {}

			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				local job = QBCore.Functions.GetPlayer(player.PlayerData.source).PlayerData.job

				userGroupsFormat[job.name] = { hierarchyName = job.grade.level }
				
				local userGroups = QBCore.Functions.GetPermission(player.PlayerData.source)
				for group,status in pairs(userGroups) do
					if status then
						userGroupsFormat[group] = { hierarchyName = "" }
					end
				end
			else
				--? Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
				if player then
					local job = player.PlayerData.job
					userGroupsFormat[job.name] = { hierarchyName = job.grade.level }
				end
			end

			return userGroupsFormat
		end,
		
		getAllUserGroups = function()
			local rows = MySQL.Sync.fetchAll("SELECT * FROM players")
			if #rows > 0 then
				for rowNumber,rowInfos in pairs(rows) do
					local user_id = rowInfos.citizenid
					local userGroups = Functions["server"].getUserGroups(user_id)
					for group,infos in pairs(userGroups) do
						if enable then
							if not allUserGroups[group] then
								allUserGroups[group] = {}
							end
							table.insert( allUserGroups[group], { user_id = user_id, hierarchyName = infos.hierarchyName } )
						end
					end
				end
			end

			return allUserGroups
		end,

		addUserGroup = function(user_id,group)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.SetJob(group, 1)
			else
				--? Player Offline
				local jobInfo = QBCore.Shared.Jobs[group]
				if jobInfo then
					local jobGradeInfo = jobInfo.grades[tostring(1)]	
					local job = {}
					job.name = group
					job.label = jobInfo.label
					job.payment = jobGradeInfo.payment
					job.onduty = true
					job.isboss = false
					job.grade = {}
					job.grade.name = jobGradeInfo.name
					job.grade.isboss = job.isboss
					job.grade.level = 1
					job.grade.payment = jobGradeInfo.payment
					job.type = jobInfo.type or 'none'
					MySQL.Sync.fetchAll('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), user_id })
					return true
				end

				return false
			end
		end,

		removeUserGroup = function(user_id,group)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.SetJob("unemployed", '0')
			else
				--? Player Offline
				local job = {}
				job.name = "unemployed"
				job.label = "Unemployed"
				job.payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500
				job.onduty = true
				job.isboss = false
				job.grade = {}
				job.grade.name = nil
				job.grade.level = 0
				MySQL.Sync.fetchAll('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), user_id })
				return true
			end
		end,

		giveHandMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.AddMoney('cash', tonumber(amount))
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local playerMoney = json.decode(data[1].money)
					playerMoney.cash = tonumber(playerMoney.cash) + tonumber(amount)
					MySQL.Sync.fetchAll('UPDATE players SET money = @money WHERE citizenid = @citizenid', {["money"] = json.encode(playerMoney), ["citizenid"] = user_id})
					return true
				else
					return false
				end
			end
		end,

		removeHandMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.RemoveMoney('cash', amount)
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local playerMoney = json.decode(data[1].money)
					playerMoney.cash = tonumber(playerMoney.cash) - tonumber(amount)
					if playerMoney.cash > 0  then
						MySQL.Sync.fetchAll('UPDATE players SET money = @money WHERE citizenid = @citizenid', {["money"] = json.encode(playerMoney), ["citizenid"] = user_id})
						return true
					else
						return false
					end
				else
					return false
				end
			end
		end,

		getHandMoney = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			return player.PlayerData.money.cash
		end,

		giveBankMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.AddMoney('bank', tonumber(amount), "Bank depost")
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local playerMoney = json.decode(data[1].money)
					playerMoney.bank = tonumber(playerMoney.cash) + tonumber(amount)
					MySQL.Sync.fetchAll('UPDATE players SET money = @money WHERE citizenid = @citizenid', {["money"] = json.encode(playerMoney), ["citizenid"] = user_id})
					return true
				else
					return false
				end
			end
		end,

		removeBankMoney = function(user_id, amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.RemoveMoney('bank', amount, "Bank depost")
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT money FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local playerMoney = json.decode(data[1].money)
					playerMoney.bank = tonumber(playerMoney.cash) - tonumber(amount)
					if playerMoney.bank > 0  then
						MySQL.Sync.fetchAll('UPDATE players SET money = @money WHERE citizenid = @citizenid', {["money"] = json.encode(playerMoney), ["citizenid"] = user_id})
						return true
					else
						return false
					end
				else
					return false
				end
			end
		end,

		getBankMoney = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			return player.PlayerData.money.bank
		end,

		getInventoryItems = function(user_id)
			local itemsTable = {}

			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			for n, itemInfos in pairs(player.PlayerData.items) do
				itemsTable[itemInfos.name] = itemInfos.amount
			end

			return 
		end,

		getInventoryItemAmount = function(user_id,item)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				local itemInfos = player.Functions.GetItemByName(item)
				local itemAmount = 0
				if itemInfos then
					itemAmount = itemInfos.amount
				end
				return itemAmount
			else
				--? Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
				if player then
					for n,itemInfos in pairs(player.PlayerData.items) do
					 	if itemInfos.name == item then
							return itemInfos.amount
						end
					end
				end

				return 0
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.AddItem(item,amount)
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT inventory FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local hasItem = false

					local playerInventory = json.decode(data[1].inventory)
					for n, itemInfos in pairs(playerInventory) do
						if itemInfos.name == item then
							playerInventory[n].amount = itemInfos.amount + amount
							hasItem = true
							break
						end
					end

					if not hasItem then
						local itemInfo = QBCore.Shared.Items[string.lower(item)]
						if itemInfo then
							local newItemSlot = #playerInventory + 1
							playerInventory[newItemSlot] = itemInfo
							playerInventory[newItemSlot].name = item
							playerInventory[newItemSlot].amount = amount
							playerInventory[newItemSlot].info = {}
							playerInventory[newItemSlot].slot = newItemSlot
						else
							return false
						end
					end

					MySQL.Sync.fetchAll('UPDATE players SET inventory = @inventory WHERE citizenid = @citizenid', {["inventory"] = json.encode(playerInventory), ["citizenid"] = user_id})
					return true
				end

				return false
			end
		end,

		removeInventoryItem = function(user_id,item,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return player.Functions.RemoveItem(item,amount)
			else
				--? Player Offline
				local data = MySQL.Sync.fetchAll('SELECT inventory FROM players WHERE citizenid = @citizenid', { ["citizenid"] = user_id })
				if data[1] then
					local playerInventory = json.decode(data[1].inventory)
					for n, itemInfos in pairs(playerInventory) do
						if itemInfos.name == item then
							if itemInfos.amount < amount then
								return false
							else
								playerInventory[n].amount = itemInfos.amount - amount
								MySQL.Sync.fetchAll('UPDATE players SET inventory = @inventory WHERE citizenid = @citizenid', {["inventory"] = json.encode(playerInventory), ["citizenid"] = user_id})
								return true
							end
						end
					end
				end

				return false
			end
		end,

		getInventoryWeight = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			return exports['qb-inventory']:GetTotalWeight(player.PlayerData.items)
		end,

		getInventoryMaxWeight = function(user_id)
			return 120000
		end,

		getItemWeight = function(item)
			if item == "" then
				return ""
			end
			return QBCore.Shared.Items[item] and QBCore.Shared.Items[item].weight or 0.0
		end,

		getItemName = function(item)
			if item == "" then
				return ""
			end
			return QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label or item
		end,

		getItemIndex = function(item)
			if item == "" then
				return ""
			end
			local index = QBCore.Shared.Items[item] and QBCore.Shared.Items[item].image or item
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

		getUserVehicles = function(user_id)
			local vehiclesInfos = {}

			local rows = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {
				["@citizenid"] = user_id
			})

			if #rows >= 1 then
				for n,vehicleInfo in pairs(rows) do
					table.insert(vehiclesInfos,
						{
							model = vehicleInfo.vehicle,
							plate = vehicleInfo.plate,
							arest = vehicleInfo.state, 
							engineHealth = vehicleInfo.enigne, 
							bodyHealth = vehicleInfo.body,
							fuel = vehicleInfo.fuel,
							taxTime = 0,
							odometer = 0,
							tunning = {},
							damage = {}
						}
					)
				end
			end

			return vehiclesInfos
		end,

		saveOutfit = function(source,outfit)
			local currentOutfit = ""

			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})

			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				currentOutfit = json.decode(savedOutfit)
			else
				savedOutfit = ""
				currentOutfit = outfit
				MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit",
					["@txt"] = json.encode(outfit)
				})
			end
			
			local rIdle = {}
			for k,v in pairs(currentOutfit) do
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
				savedOutfit = json.decode(savedOutfit[1].txt) or {}
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
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			return player.PlayerData.metadata.injail
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
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end

			player = player.PlayerData
			info["name"] = player.charinfo.firstname
			info["lastName"] = player.charinfo.lastname
			info["age"] = player.charinfo.birthdate
			info["document"] = user_id
			info["phone"] = player.charinfo.phone
			return info
		end,

		getHealth = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				local ped = GetPlayerPed(player.PlayerData.source)
				return GetEntityHealth(ped)
			else
				--? Player Offline
				return false
			end

			return false
		end,

		setHealth = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				getTunnelInformation(player.PlayerData.source,"setHealth","functions",amount)
				return true
			else
				--? Player Offline
				return false
			end

			return false
		end,

		getArmour = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end
			
			return PlayerData.metadata.armor
		end,

		setArmour = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				player.Functions.SetMetaData('armor', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, player.PlayerData.metadata.hunger, amount)
			else
				--? Player Offline
				local infosDB = MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				local metadata = json.decode(infosDB[1].metadata)
				
				metadata.armor = amount
				return MySQL.Sync.fetchAll("UPDATE players SET metadata = @metadata WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
			end

			return false
		end,

		getHunger = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end
			
			return PlayerData.metadata.hunger
		end,

		setHunger = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				player.Functions.SetMetaData('hunger', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, amount, player.PlayerData.metadata.thirst)
			else
				--? Player Offline
				local infosDB = MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				local metadata = json.decode(infosDB[1].metadata)
				
				metadata.hunger = amount
				return MySQL.Sync.fetchAll("UPDATE players SET metadata = @metadata WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
			end

			return false
		end,

		getThirst = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end
			
			return PlayerData.metadata.thirst
		end,

		setThirst = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				player.Functions.SetMetaData('thirst', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, player.PlayerData.metadata.hunger, amount)
			else
				--? Player Offline
				local infosDB = MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				local metadata = json.decode(infosDB[1].metadata)
				
				metadata.thirst = amount
				return MySQL.Sync.fetchAll("UPDATE players SET metadata = @metadata WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
			end

			return false
		end,

		getStress = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if not player then
				--? Get Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
			end
			
			return PlayerData.metadata.stress
		end,

		setStress = function(user_id,amount)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				player.Functions.SetMetaData('stress', amount)
				TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, player.PlayerData.metadata.hunger, amount)
			else
				--? Player Offline
				local infosDB = MySQL.Sync.fetchAll("SELECT metadata FROM players WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
				})
				local metadata = json.decode(infosDB[1].stress)
				
				metadata.thirst = amount
				return MySQL.Sync.fetchAll("UPDATE players SET metadata = @metadata WHERE citizenid = @citizenid", {
					["@citizenid"] = user_id,
					["@metadata"] = json.encode(metadata),
				})
			end

			return false
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

			if Config.resources["striata_advancedfuel"] then
				local advancedFuelConfig, advancedFuelLangs = exports['striata_resources']:striata_advancedFuel_config()

				QBCore.Functions.CreateUseableItem("galao-gasoline", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","gasoline")
					end
				end)

				QBCore.Functions.CreateUseableItem("galao-diesel", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","diesel")
					end
				end)

				QBCore.Functions.CreateUseableItem("galao-gas", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","gas")
					end
				end)

				QBCore.Functions.CreateUseableItem("galao-ethanol", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","ethanol")
					end
				end)

				QBCore.Functions.CreateUseableItem("galao-avGas", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","avGas")
					end
				end)

				QBCore.Functions.CreateUseableItem("bateria", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"battery","energy")
					end
				end)

				QBCore.Functions.CreateUseableItem("sacocomcarvao", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","coal")	
					end
				end)

				QBCore.Functions.CreateUseableItem("balde-animalfeed", function(source, item)
					local Player = QBCore.Functions.GetPlayer(source)
					if Player.Functions.GetItemByName(item.name) ~= nil then
						TriggerClientEvent("striata:fuel:refuel",source,"gallon","animalfeed")	
					end
				end)
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			local rows = MySQL.Sync.fetchAll("SELECT * FROM player_houses WHERE houses = @houses", {
				["@houses"] = homeName,
			})
			if rows[1] then
				for n, userAcessKey in pairs(rows[1].keyholders) do 
					if userAcessKey == user_id then
						return true
					end
				end
			end
			
			TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
			return false
		end,

		getWhiteListStatus = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				return QBCore.Functions.IsWhitelisted(player.PlayerData.source)
			else
				return false
			end
			
		end,

		changeWhiteListStatus = function(user_id,status)
			if status then
				ExecuteCommand(('add_principal player.%s qbcore.%s'):format(user_id, "admin"))
			else
				ExecuteCommand(('remove_principal player.%s qbcore.%s'):format(user_id, "admin"))
			end
			return false
		end,

		getBanStatus = function(user_id)
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
			if player then
				--? Player Online
				return QBCore.Functions.IsPlayerBanned(player.PlayerData.source)
			else
				--? Player Offline
				player = QBCore.Functions.GetOfflinePlayerByCitizenId(user_id)
				local playerInfos = MySQL.Sync.fetchAll("SELECT * FROM bans WHERE license = @license", {
					["@citizenid"] = player.PlayerData.license,
				})

				if #playerInfos >= 1 then
					return true
				end

				return false
			end
		end,
		
		setBanStatus = function(user_id,toogle,reason)
			if not toogle then
				toogle = true
			end
			
			local player = QBCore.Functions.GetPlayerByCitizenId(user_id)

			if player then
				player = player.PlayerData
				local source = player.source
				MySQL.Sync.fetchAll('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name,@license,@discord,@ip,@reason,@expire,@bannedby)', {
					["@name"] = player.charinfo.firstname.." "..player.charinfo.lastname,
					["@license"] = QBCore.Functions.GetIdentifier(source, 'license'),
					["@discord"] = QBCore.Functions.GetIdentifier(source, 'discord'),
					["@ip"] = QBCore.Functions.GetIdentifier(source, 'ip'),
					["@reason"] = "striata resources ban",
					["@expire"] = 4102444800,
					["@bannedby"] = 'striata_resources'
				})

				if status and source then
					DropPlayer(source, reason)
				end
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

		checkPlayerIsDiscordMember = function(user_id,discordId)
			if Config.resources["striata_discordbot"] then
				return exports["striata_resources"]:checkIsMember(user_id,discordId)
			else
				return false
			end
		end
	}
}
Events.QBCore = {
	client = {
		playerSpawn = "QBCore:Client:OnPlayerLoaded",
		groupChange = {"QBCore:Client:OnShareUpdate"}
	},
	server = {
		playerSpawn = "QBCore:Server:OnPlayerLoaded",
		groupChange = {"QBCore:Server:UpdateObject"}
	}
}

Functions.VORP = {
	client = {
		getSharedObject = function()
			return exports.vorp_core:GetCore()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		request = function(text, time)
			local MenuData = exports.vorp_menu:GetMenuData()

			local timeOut = false
			local response

			local elements = {
				{
					label = "Aceitar",
					value = true,
					desc = ""
				},
				{
					label = "Rejeitar",
					value = false,
					desc = ""
				}
			}

			MenuData.Open('default', GetCurrentResourceName(), 'request'..math.random(1,9999),
				{
					title = "Confirmação",
					subtext = text,
					align = "top-left",
					elements = elements
			
				},
				function(data, menu)
					response = data.current.value

					if response == "true" then
						response = true
					elseif response == "false" then
						response = false
					end
				end,

				function(data, menu)
					response = false
				end
			)

			local time = 10
			SetTimeout(1000*10,function()
				time = 1000
			end)

			SetTimeout(1000*time,function()
				timeOut = true
			end)

			repeat
				Wait(time)
			until(timeOut or response ~= nil)

			if not response then
				MenuData.CloseAll()
				return false
			else
				MenuData.CloseAll()
				return true
			end
		end,

		textInput = function(text, input)
			local myInput = {
				type = "enableinput", -- dont touch
				inputType = "input",
				button = "Confirmar", -- button name
				placeholder = input, --placeholdername
				style = "block", --- dont touch
				attributes = {
					value = input, -- input value
					inputHeader = text, -- header
					-- type = type, -- inputype text, number,date.etc if number comment out the pattern
					-- pattern = pattern, -- regular expression validated for only numbers "[0-9]", for letters only [A-Za-z]+   with charecter limit  [A-Za-z]{5,20}     with chareceter limit and numbers [A-Za-z0-9]{5,}
					-- title = errormsg, -- if input doesnt match show this message
					style = "border-radius: 10px; background-color: ; border:none;", -- style  the inptup
				}
			}

			-- return exports.vorp_inputs:advancedInput(myInput) or ""

			local response
			local endTime = false

			SetTimeout(1000*60*2,function()
				endTime = true
			end)

			TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(cb)
				response = tostring(cb)
				endTime = true
			end)

			local time = 10
			SetTimeout(1000*10,function()
				time = 1000
			end)

			repeat
				Wait(time)
			until(endTime)
			
			return response

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
			
			return true
		end,

		getOutfit = function()
			local ped = PlayerPedId()
			local source = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
			local custom = {}
			custom.modelhash = GetEntityModel(ped)
			local playerAllComponents = exports["vorp_character"]:GetAllPlayerComponents()
			for category, value in pairs(playerAllComponents) do
				custom[category] = { value.comp, value.palette, value.tint0, value.tint1, value.tint2}
			end
			
			return custom
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

				local vorpMetaPedCategoryTags = {
					maleTags = {
						[`accessories`]         = "Accessories",
						[`ammo_pistols`]        = "ammo_pistols",
						[`ammo_rifles`]         = "ammo_rifles",
						[`ankle_bindings`]      = "ankle_bindings",
						[`aprons`]              = "aprons",
						[`armor`]               = "Armor",
						[`badges`]              = "Badge",
						[`beards_chin`]         = "beards_chin",
						[`beards_chops`]        = "beards_chops",
						[`beards_complete`]     = "beards_complete",
						[`beards_mustache`]     = "beards_mustache",
						[`belts`]               = "Belts",
						[`belt_buckles`]        = "Buckle",
						[`bodies_lower`]        = "Boots",
						[`bodies_upper`]        = "bodies_upper",
						[`boots`]               = "boots",
						[`boot_accessories`]    = "Spurs",
						[`chaps`]               = "Chap",
						[`cloaks`]              = "Cloak",
						[`coats`]               = "Coat",
						[`coats_closed`]        = "CoatClosed",
						[`coats_heavy`]         = "coats_heavy",
						[`dresses`]             = "Dress",
						[`eyebrows`]            = "eyebrows",
						[`eyes`]                = "eyes",
						[`eyewear`]             = "EyeWear",
						[`gauntlets`]           = "Gauntlets",
						[`gloves`]              = "Glove",
						[`gunbelt_accs`]        = "GunbeltAccs",
						[`gunbelts`]            = "Gunbelt",
						[`hair`]                = "hair",
						[`hair_accessories`]    = "hair_accessories",
						[`hats`]                = "Hat",
						[`heads`]               = "heads",
						[`holsters_crossdraw`]  = "holsters_crossdraw",
						[`holsters_knife`]      = "holsters_knife",
						[`holsters_left`]       = "Holster",
						[`holsters_right`]      = "holsters_right",
						[`jewelry_bracelets`]   = "Vracelet",
						[`jewelry_rings_left`]  = "RingLh",
						[`jewelry_rings_right`] = "RingRh",
						[`loadouts`]            = "Loadouts",
						[`masks`]               = "Mask",
						[`masks_large`]         = "masks_large",
						[`neckties`]            = "NeckTies",
						[`neckwear`]            = "NeckWear",
						[`outfits`]             = "outfits",
						[`pants`]               = "Pant",
						[`ponchos`]             = "Poncho",
						[`satchels`]            = "Satchels",
						[`shirts_full`]         = "Shirt",
						[`skirts`]              = "Skirt",
						[`spats`]               = "Spats",
						[`suspenders`]          = "Suspenders",
						[`teeth`]               = "teeth",
						[`vests`]               = "Vest",
						[`wrist_bindings`]      = "wrist_bindings",
					},
				
					femaleTags = {
						[`accessories`]         = "Accessories",
						[`ammo_pistols`]        = "ammo_pistols",
						[`ammo_rifles`]         = "ammo_rifles",
						[`ankle_bindings`]      = "ankle_bindings",
						[`aprons`]              = "aprons",
						[`armor`]               = "Armor",
						[`badges`]              = "Badge",
						[`beards_chin`]         = "beards_chin",
						[`beards_chops`]        = "beards_chops",
						[`beards_complete`]     = "beards_complete",
						[`beards_mustache`]     = "beards_mustache",
						[`belts`]               = "Belts",
						[`belt_buckles`]        = "Buckle",
						[`bodies_lower`]        = "Boots",
						[`bodies_upper`]        = "bodies_upper",
						[`boots`]               = "boots",
						[`boot_accessories`]    = "Spurs",
						[`chaps`]               = "Chap",
						[`cloaks`]              = "Cloak",
						[`coats`]               = "Coat",
						[`coats_closed`]        = "CoatClosed",
						[`coats_heavy`]         = "coats_heavy",
						[`dresses`]             = "Dress",
						[`eyebrows`]            = "eyebrows",
						[`eyes`]                = "eyes",
						[`eyewear`]             = "EyeWear",
						[`gauntlets`]           = "Gauntlets",
						[`gloves`]              = "Glove",
						[`gunbelt_accs`]        = "GunbeltAccs",
						[`gunbelts`]            = "Gunbelt",
						[`hair`]                = "hair",
						[`hair_accessories`]    = "hair_accessories",
						[`hats`]                = "Hat",
						[`heads`]               = "heads",
						[`holsters_crossdraw`]  = "holsters_crossdraw",
						[`holsters_knife`]      = "holsters_knife",
						[`holsters_left`]       = "Holster",
						[`holsters_right`]      = "holsters_right",
						[`jewelry_bracelets`]   = "Vracelet",
						[`jewelry_rings_left`]  = "RingLh",
						[`jewelry_rings_right`] = "RingRh",
						[`loadouts`]            = "Loadouts",
						[`masks`]               = "Mask",
						[`masks_large`]         = "masks_large",
						[`neckties`]            = "NeckTies",
						[`neckwear`]            = "NeckWear",
						[`outfits`]             = "outfits",
						[`pants`]               = "Pant",
						[`ponchos`]             = "Poncho",
						[`satchels`]            = "Satchels",
						[`shirts_full`]         = "Shirt",
						[`skirts`]              = "Skirt",
						[`spats`]               = "Spats",
						[`suspenders`]          = "Suspenders",
						[`teeth`]               = "teeth",
						[`vests`]               = "Vest",
						[`wrist_bindings`]      = "wrist_bindings"
					}
				}
				local categoryHashList = {
					Gunbelt     = 0x9B2C8B89,
					Mask        = 0x7505EF42,
					Holster     = 0xB6B6122D,
					Loadouts    = 0x83887E88,
					Coat        = 0xE06D30CE,
					Cloak       = 0x3C1A74CD,
					EyeWear     = 0x5E47CA6,
					Bracelet    = 0x7BC10759,
					Skirt       = 0xA0E3AB7F,
					Poncho      = 0xAF14310B,
					Spats       = 0x514ADCEA,
					NeckTies    = 0x7A96FACA,
					Spurs       = 0x18729F39,
					Pant        = 0x1D4C528A,
					Suspender   = 0x877A2CF7,
					Glove       = 0xEABE0032,
					Satchels    = 0x94504D26,
					GunbeltAccs = 0xF1542D11,
					CoatClosed  = 0x662AC34,
					Buckle      = 0xFAE9107F,
					RingRh      = 0x7A6BBD0B,
					Belt        = 0xA6D134C6,
					Accessories = 0x79D7DF96,
					Shirt       = 0x2026C46D,
					Gauntlets   = 0x91CE9B20,
					Chap        = 0x3107499B,
					NeckWear    = 0x5FC29285,
					Boots       = 0x777EC6EF,
					Vest        = 0x485EE834,
					RingLh      = 0xF16A1D23,
					Hat         = 0x9925C067,
					Dress       = 0xA2926F9B,
					Badge       = 0x3F7F3587,
					armor       = 0x72E6EF74,
					Hair        = 0x864B03AE,
					Beard       = 0xF8016BCA,
					bow         = 0x8E84A2AA,
				}

				if mhash then
					local i = 0
					while not HasModelLoaded(mhash) and i < 10000 do
						RequestModel(mhash)
						Citizen.Wait(10)
					end
					
					local isPedMale = IsPedMale(ped)
					if HasModelLoaded(mhash) then
						local weapons = Functions["client"].getWeapons()
						local health = GetEntityHealth(ped)
						SetPlayerModel(PlayerId(),mhash)

						ped = PlayerPedId()
						
						if isPedMale then
							EquipMetaPedOutfitPreset(ped, 3)
						else
							EquipMetaPedOutfitPreset(ped, 7)
						end

						local pedReadyToRender = IsPedReadyToRender(ped)
						while not pedReadyToRender or pedReadyToRender == 0 do
							pedReadyToRender = IsPedReadyToRender(ped)
							Wait(1)
						end
						UpdatePedVariation(ped)

						SetPedMaxHealth(ped,maxHealt)
						SetEntityHealth(ped,health)
						Functions["client"].giveWeapons(weapons,true)
						SetModelAsNoLongerNeeded(mhash)
					end
				else
					for categoty, hash in pairs(categoryHashList) do
						RemoveTagFromMetaPed(ped,hash)
					end
				end

				local function setComps(ped,category,infos)
					RemoveTagFromMetaPed(ped,categoryHashList[category])
					
					ApplyShopItemToPed(ped, infos.comp, false, false, false)
					ApplyShopItemToPed(ped, infos.comp, false, true, false)

					if category ~= "Boots" then
						UpdateShopItemWearableState(ped, `base`)
					end
					
					if category == "Glove" then
						ApplyShopItemToPed(ped, 3746704442, false, false, false)
						ApplyShopItemToPed(ped, 3746704442, false, true, false)
					elseif category == "Boots" then
						ApplyShopItemToPed(ped, 2539219498, false, false, false)
						ApplyShopItemToPed(ped, 2539219498, false, true, false)
					end

					Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
					UpdatePedVariation(ped, false, true, true, true, false)
					local pedReadyToRender = IsPedReadyToRender(ped)
					while not pedReadyToRender or pedReadyToRender == 0 do
						pedReadyToRender = IsPedReadyToRender(ped)
						Wait(1)
					end

					if (infos.tint0 ~= 0 or infos.tint1 ~= 0 or infos.tint2 ~= 0) and infos.palette ~= 0 then
						local numComponents = GetNumComponentsInPed(ped)
						for i = 0, numComponents - 1, 1 do
							local componentCategory = Citizen.InvokeNative(0x9b90842304c938a7, ped, i, 0, Citizen.ResultAsInteger())
							if vorpMetaPedCategoryTags[isPedMale and "maleTags" or "femaleTags"][componentCategory] == (category == "Boots" and "boots" or category) then
								local componentIndex = i
								
								local drawable, albedo, normal, material = GetMetaPedAssetGuids(playerPed, componentIndex)
								local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)
								local palette = (infos.palette ~= 0) and infos.palette or palett
								SetMetaPedTag(ped, drawable, albedo, normal, material, palette, infos.tint0, infos.tint1, infos.tint2)
								
								break
							end
						end
					end
				end
				
				for category,value in pairs(outfit) do
					if category ~= "model" and category ~= "modelhash" then
						local infos = {
							comp = tonumber(value[1]) or value[1],
							palette = value[2],
							tint0 = value[3],
							tint1 = value[4],
							tint2 = value[5]
						}
						
						if infos.comp ~= -1 then
							setComps(ped,category,infos)
						end
					end
				end

				Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
				UpdatePedVariation(ped, false, true, true, true, false)
				local pedReadyToRender = IsPedReadyToRender(ped)
				while not pedReadyToRender or pedReadyToRender == 0 do
					pedReadyToRender = IsPedReadyToRender(ped)
					Wait(1)
				end
				SetPedScale(ped, 1.0)
				return true
			else
				return false
			end
		end,

		setPlayerHandcuffed = function(toggle)
			SetEnableHandcuffs(player, toggle)
		end,

		teleportPlayer = function(x,y,z)
			local ped = PlayerPedId()
			
			local vehicle = GetVehiclePedIsIn(ped, false)
			if vehicle then
				DeleteEntity(vehicle)
			end

			DetachEntity(ped, true, false)

			SetEntityCoords(ped, vector3(x,y,z), false, false, false, false)
		end,

		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		playSoundByGame = function(dict,name)
			PlaySoundFrontend(dict,name, true, 0)
		end,

		getNearestVehicles = function(radius)
			local r = {}
			local coords = GetEntityCoords(PlayerPedId())
		
			local vehs = {}
			local trains = {}

			local it, veh = FindFirstVehicle()
			if veh then
				if IsThisModelATrain(GetEntityModel(veh)) then
					table.insert(trains, veh)
				else
					table.insert(vehs, veh)
				end
			end
			local ok
			repeat
				ok, veh = FindNextVehicle(it)
				if ok and veh then
					if IsThisModelATrain(GetEntityModel(veh)) then
						table.insert(trains, veh)
					else
						table.insert(vehs, veh)
					end
				end
			until not ok
			EndFindVehicle(it)
		
			local peds = {}

			local itPed, ped = FindFirstPed()
			if ped then
				table.insert(peds, ped)
			end
			repeat
				ok, ped = FindNextPed(itPed)
				if ok and ped then
					table.insert(peds, ped)
				end
			until not ok
			EndFindPed(itPed)
		
			local trainsLastTracks = {}
			for n, train in pairs(trains) do
				if not trainsLastTracks[tostring(GetTrainCar(train))] then
					trainsLastTracks[tostring(GetTrainCar(train))] = GetTrainCarriageTrailerNumber(train)
				end
			end

			local function getPrevTracket(currentTraker)
				for n,trainEntity in pairs(trains) do
					if GetTrainCarriage(trainEntity,1) == currentTraker then
						return trainEntity
					end
				end
			end

			local trainsMinDistance = {}
			for stringLastTrackEntity, amountTracksInCurrentTrain in pairs(trainsLastTracks) do
				local prevTracket = tonumber(stringLastTrackEntity)
				trainsMinDistance[stringLastTrackEntity] = #(coords - GetEntityCoords(prevTracket))
				for i = 1, (amountTracksInCurrentTrain - 1) do
					local oldPrevTracket = prevTracket
					prevTracket = getPrevTracket(prevTracket)

					local tracketDistace = #(coords - GetEntityCoords(prevTracket))
					trainsMinDistance[tostring(prevTracket)] = tracketDistace < trainsMinDistance[tostring(oldPrevTracket)] and tracketDistace or trainsMinDistance[tostring(oldPrevTracket)]
					trainsMinDistance[tostring(oldPrevTracket)] = nil

					if i == (amountTracksInCurrentTrain - 1) then
						table.insert(vehs, prevTracket)
					end
				end
			end

			for n, ped in pairs(peds) do
				if IsThisModelAHorse(GetEntityModel(ped)) ~= 0 and GetVehicleDraftHorseIsAttachedTo(ped) == 0 then
					table.insert(vehs, ped)
				end
			end
		
			for n, veh in pairs(vehs) do
				local coordsVeh = GetEntityCoords(veh)
				local distance = trainsMinDistance[tostring(veh)] or #(coords - coordsVeh)
				if distance <= radius then
					r[veh] = distance
				end
			end
			return r
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
			local allPlayers = GetActivePlayers()
			local players = {}
			local currentPedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
			for n,playerId in pairs(allPlayers) do
				if GetPlayerServerId(playerId) ~= currentPedId then
					local player = GetPlayerPed(playerId)
					local coords = GetEntityCoords(PlayerPedId())
					local pedCoords = GetEntityCoords(player)
					local distance = #(pedCoords - coords)
					players[GetPlayerServerId(playerId)] = distance
				end
			end
			return players
		end,

		getNearestPlayer = function(radius)			
			for player, distance in pairs(Functions["client"]:getNearestPlayers(radius)) do
				if distance <= radius then
					return player
				end
			end
			return false
		end,

		killGod = function()
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			Functions["client"].setHealth(120)
			ClearPedTasks(ped)
			ClearPedSecondaryTask(ped)
			return true
		end,

		getHealth = function()
			return GetEntityHealth(PlayerPedId())
		end,
	
		setHealth = function(health)
			local ped = PlayerPedId()
			if health >= 1 and IsEntityDead(ped) then
				TriggerEvent("vorp:resurrectPlayer",true)
			end

			SetEntityHealth(ped,tonumber(health))
			
			return true
		end,

		addBlip = function(x,y,z,idtype,idcolor,text,scale,route)
			local blip = BlipAddForCoords(GetHashKey("BLIP_MODIFIER_RADAR_EDGE_NEVER"),tonumber(x),tonumber(y),tonumber(z))
			SetBlipSprite(blip,idtype)
			BlipAddModifier(blip, idcolor)
			SetBlipScale(blip,scale)

			if route then
				StartGpsMultiRoute(`COLOR_RED`, true, true)
				AddPointToGpsMultiRoute(tonumber(x),tonumber(y),tonumber(z))
    	    	SetGpsMultiRouteRender(true, 8, 8)
			end

			if text then
				SetBlipName(blip,text)
			end
			return blip
		end,

		removeBlip = function(blipId,removeRoute)
			RemoveBlip(blipId)
			if removeRoute then
				ClearGpsMultiRoute()
			end
		end,

		AddTargetModel = function(models,configuration)
			return false
		end,

		fxHudSetStatus = function(status,amount) --? Exclusive fx-hud script
			exports['fx-hud']:setStatus(status,amount)
		end,
		
		fxHudGetStatus = function(status) --? Exclusive fx-hud script
			exports['fx-hud']:getStatus(status)
		end
	},

	server = {
		getSharedObject = function()
			return exports["vorp_core"]:GetCore()
		end,

		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end

			local steam

			for n,identifier in pairs(identifiers) do
				if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
					steam = identifier
					break
				end
			end

			return steam
		end,

		getUserId = function(source)
			local user = VorpCore.getUser(source)
			return user and user.getUsedCharacter.charIdentifier 
		end,

		getUserSource = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			if user then
				return user.source
			else
				return nil
			end
		end,

		getUsers = function()
			local users = {}
			for k,v in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(v))
				if user_id then
					users[user_id] = v
				end
			end
			return users
		end,

		getUsersByPermission = function(perm)
			local users = {}
			for n,source in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(source))
				if Functions["server"].hasPermission(user_id,perm) then
					table.insert(users,user_id)
				end
			end
			return users
		end,

		hasPermission = function(user_id, perm)
			local user = VorpCore.getUserByCharId(user_id)
			
			local job
			local group
			
			if user then
				job = user.getUsedCharacter.job
				group = user.getUsedCharacter.group
			end

			local rows =  MySQL.Sync.fetchAll("SELECT * FROM characters WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = (user_id),
			})

			local vips = {}
			if rows[1] and rows[1].vips then
				local currentVipsTable = rows[1].vips and json.decode(rows[1].vips)
				if currentVipsTable ~= "{}" then
					vips = currentVipsTable
				end
			end

			
			if not perm or perm == "" or perm == job or perm == group or vips[perm] then
				return true
			end
			
			return false
		end,

		getUserGroups = function(user_id)
			local userGroupsFormat = {}
			
			local rows =  MySQL.Sync.fetchAll("SELECT * FROM characters WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = (user_id),
			})

			if Functions["server"].getUserSource(tonumber(user_id)) then
				--? Player Online
				local user = VorpCore.getUserByCharId(user_id)
				if user then
					userGroupsFormat[user.getUsedCharacter.job] = { hierarchyName = user.getUsedCharacter.jobGrade }
					userGroupsFormat[user.getUsedCharacter.group] = { hierarchyName = "" }
				end
			else
				--? Player Offline
				if rows[1] and rows[1].job and rows[1].jobGrade  then
					userGroupsFormat[rows[1].job] = { hierarchyName = rows[1].jobGrade}
				end
				if rows[1] and rows[1].group then
					userGroupsFormat[rows[1].group] = { hierarchyName = "" }
				end
			end

			if rows[1] and rows[1].vips then
				local currentVipsTable = rows[1].vips and json.decode(rows[1].vips)
				if currentVipsTable ~= "{}" then
					for n,vip in pairs(currentVipsTable) do
						userGroupsFormat[vip] = { hierarchyName = "" }
					end
				end
			end

			return userGroupsFormat
		end,

		getAllUserGroups = function()
			local allUserGroups = {}
			local rows = MySQL.Sync.fetchAll("SELECT * FROM characters")
			
			for rowNumber,rowInfos in pairs(rows) do
				local user_id = rowInfos.charidentifier
				if rowInfos.group and rowInfos.group ~= "" then
					if not allUserGroups[rowInfos.group] then
						allUserGroups[rowInfos.group] = {}
					end
					table.insert( allUserGroups[rowInfos.group], { user_id = user_id, hierarchyName = "" } )
				end
				
				if rowInfos.job and rowInfos.job ~= "" then
					if not allUserGroups[rowInfos.job] then
						allUserGroups[rowInfos.job] = {}
					end
					table.insert( allUserGroups[rowInfos.job], { user_id = user_id, hierarchyName = rowInfos.jobgrade } )
				end

				if rowInfos.vips and json.decode(rowInfos.vips) ~= "{}" then
					local vips = json.decode(rowInfos.vips)

					for vip, enable in pairs(vips) do
						if enable and not allUserGroups[vip] then
							allUserGroups[vip] = {}
						end
						table.insert( allUserGroups[vip], { user_id = user_id, hierarchyName = "" } )
					end
				end
			end

			return allUserGroups
		end,

		addUserGroup = function(user_id,group,grade)
			user_id = tonumber(user_id)
			grade = tonumber(grade)

			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				local user = VorpCore.getUserByCharId(user_id)
				character = user.getUsedCharacter
				local itemSplit = Functions["default-server"].striata_splitString(group,"|")
				if itemSplit[2] then
					if string.sub(group, 1, string.len("group|")) == "group|" then
						character.setGroup(itemSplit[2])
	
					elseif string.sub(group, 1, string.len("job|")) == "job|" then
						character.setJob(itemSplit[2])
						character.setJobGrade(grade)
	
					elseif string.sub(group, 1, string.len("vip|")) == "vip|" then
						
						local vipRows = MySQL.Sync.fetchAll("SELECT vips FROM characters WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
						})
						vips = json.decode(vipRows[1].vips)
		
						vips[itemSplit[2]] = true
						return MySQL.Sync.fetchAll("UPDATE characters SET vips = @vips WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@vips"] = json.encode(vips),
						})
					end
				end
			else
				--? Player Offline
				local itemSplit = Functions["default-server"].striata_splitString(group,"|")
				if itemSplit[2] then
					if string.sub(group, 1, string.len("group|")) == "group|" then
	
						return MySQL.Sync.fetchAll("UPDATE characters SET group = @group WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@group"] = itemSplit[2],
						})
					elseif string.sub(group, 1, string.len("job|")) == "job|" then
						
						MySQL.Sync.fetchAll("UPDATE characters SET job = @job WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@job"] = itemSplit[2],
						})
	
						MySQL.Sync.fetchAll("UPDATE characters SET jobgrade = @jobgrade WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@jobgrade"] = grade,
						})
	
						return true
					elseif string.sub(group, 1, string.len("vip|")) == "vip|" then
						
						local vipRows = MySQL.Sync.fetchAll("SELECT vips FROM characters WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
						})
						vips = json.decode(vipRows[1].vips)
		
						vips[itemSplit[2]] = true
						return MySQL.Sync.fetchAll("UPDATE characters SET vips = @vips WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@vips"] = json.encode(vips),
						})
					end
				end
			end
			return false
		end,

		removeUserGroup = function(user_id,group)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				local user = VorpCore.getUserByCharId(user_id)
				character = user.getUsedCharacter
				if string.sub(group, 1, string.len("group|")) == "group|" then
					local itemSplit = Functions["default-server"].striata_splitString(group,"|")
					character.setGroup("user")

				elseif string.sub(group, 1, string.len("job|")) == "job|" then
					local itemSplit = Functions["default-server"].striata_splitString(group,"|")
					character.setJob("unemployed")
					character.setJobGrade(1)

				elseif string.sub(group, 1, string.len("vip|")) == "vip|" then
					local itemSplit = Functions["default-server"].striata_splitString(group,"|")

					local vipRows = MySQL.Sync.fetchAll("SELECT vips FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})
					vips = json.decode(vipRows[1].vips)
	
					vips[itemSplit[2]] = nil
					return MySQL.Sync.fetchAll("UPDATE characters SET vips = @vips WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@vips"] = json.encode(vips),
					})
					
				end
			else
				--? Player Offline
				if string.sub(group, 1, string.len("group|")) == "group|" then					
					return MySQL.Sync.fetchAll("UPDATE characters SET group = @group WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@group"] = "unemployed",
					})

				elseif string.sub(group, 1, string.len("job|")) == "job|" then					
					return MySQL.Sync.fetchAll("UPDATE characters SET job = @job WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@job"] = "user",
					})

				elseif string.sub(group, 1, string.len("vip|")) == "vip|" then
					local itemSplit = Functions["default-server"].striata_splitString(group,"|")

					local vipRows = MySQL.Sync.fetchAll("SELECT vips FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})
					vips = json.decode(vipRows[1].vips)
	
					vips[itemSplit[2]] = nil
					return MySQL.Sync.fetchAll("UPDATE characters SET vips = @vips WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@vips"] = json.encode(vips),
					})

				end
			end
			return false
		end,

		giveHandMoney = function(user_id, amount) --todo normal money
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user then
				--? Player Online
				character = user.getUsedCharacter
				character.addCurrency(0, amount) -- Add money 1000 | 0 = money, 1 = gold, 2 = rol
				return true
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT money FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].money then
					MySQL.Sync.fetchAll("UPDATE characters SET money = @money WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@money"] = tonumber(moneyRows[1].money) + amount,
					})
					return true
				else
					return false
				end
			end
		end,

		removeHandMoney = function(user_id, amount) --todo normal money
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user and user.getUsedCharacter.money >= amount then
				--? Player Online
				character = user.getUsedCharacter
				character.removeCurrency(0, amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
				return true
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT money FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].money and tonumber(moneyRows[1].money) >= amount then
					MySQL.Sync.fetchAll("UPDATE characters SET money = @money WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@money"] = tonumber(moneyRows[1].money) - amount,
					})
					return true
				else
					return false
				end
			end
		end,

		getHandMoney = function(user_id) --todo normal money
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user then
				--? Player Online
				return user.getUsedCharacter.money
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT money FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].money then
					return tonumber(moneyRows[1].money)
				end
			end
		end,

		giveBankMoney = function(user_id, amount) --todo gold
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user then
				--? Player Online
				character = user.getUsedCharacter
				character.addCurrency(1, amount) -- Add money 1000 | 0 = money, 1 = gold, 2 = rol
				return true
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT gold FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].gold then
					MySQL.Sync.fetchAll("UPDATE characters SET gold = @gold WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@gold"] = tonumber(moneyRows[1].gold) + amount,
					})
					return true
				else
					return false
				end
			end
		end,

		removeBankMoney = function(user_id, amount) --todo gold
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user and user.getUsedCharacter.gold >= amount then
				--? Player Online
				character = user.getUsedCharacter
				character.removeCurrency(1, amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
				return true
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT gold FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].gold and tonumber(moneyRows[1].gold) >= amount then
					MySQL.Sync.fetchAll("UPDATE characters SET gold = @gold WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@gold"] = tonumber(moneyRows[1].gold) - amount,
					})
					return true
				else
					return false
				end
			end
		end,

		getBankMoney = function(user_id) --todo gold
			local user = VorpCore.getUserByCharId(tonumber(user_id))
			if user then
				--? Player Online
				return user.getUsedCharacter.gold
			else
				--? Player Offline
				local moneyRows = MySQL.Sync.fetchAll("SELECT gold FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].gold then
					return tonumber(moneyRows[1].gold)
				end
			end
		end,

		getInventoryItems = function(user_id)
			local itemsTable = {}
			
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				local currentinventory = exports.vorp_inventory:getUserInventoryItems(source, callback)
				
				for n, itensInfos in pairs(currentinventory) do
					itemsTable[itensInfos.name] = itensInfos.count
				end

				
				local weaponsPlayer = exports.vorp_inventory:getUserInventoryWeapons(source)
				for key, value in pairs(weaponsPlayer) do
					itemsTable["wbody|WEAPON_"..value.name.."|"..value.id] = 1
				end

				local user = VorpCore.getUserByCharId(tonumber(user_id))
				if user.getUsedCharacter.rol > 0.0 then
					itemsTable["dinheirosujo"] = user.getUsedCharacter.rol
				end
			else
				--? Player Offline
				local rows = MySQL.Sync.fetchAll("SELECT * FROM character_inventories WHERE character_id = @character_id", {
					["@character_id"] = (user_id),
				})
				local rows2 = MySQL.Sync.fetchAll("SELECT * FROM loadout WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = (user_id),
				})

				for row, infos in pairs(rows) do
					itemsTable[infos.item_name] = infos.amount
				end

				for row, infos in pairs(rows2) do
					itemsTable["wbody|"..string.upper(infos.name)] = 1
				end

				local moneyRows = MySQL.Sync.fetchAll("SELECT rol FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if moneyRows[1] and moneyRows[1].rol and moneyRows[1].rol > 0.0 then
					itemsTable["dinheirosujo"] = tonumber(moneyRows[1].rol)
				end

			end

			return itemsTable
		end,

		getInventoryItemAmount = function(user_id,item)
			local inventory = exports["vorp_inventory"]:vorp_inventoryApi()
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if item == "dinheirosujo" then
					local user = VorpCore.getUserByCharId(tonumber(user_id))
					return user.getUsedCharacter.rol
				else
					return inventory.getItemCount(source,item) or 0
				end
			else
				--? Player Offline
				if item == "dinheirosujo" then
					local moneyRows = MySQL.Sync.fetchAll("SELECT rol FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})
	
					if moneyRows[1] and moneyRows[1].rol then
						return tonumber(moneyRows[1].rol)
					end
				else
					local itemsTable = {}
	
					local rows =  MySQL.Sync.fetchAll("SELECT * FROM character_inventories WHERE character_id = @character_id", {
						["@character_id"] = (user_id),
					})
					local rows2 = MySQL.Sync.fetchAll("SELECT * FROM loadout WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = (user_id),
					})
	
					for row, infos in pairs(rows) do
						itemsTable[infos.item_name] = tonumber(infos.amount)
					end
	
					for row, infos in pairs(rows2) do
						itemsTable["wbody|"..string.upper(infos.name)] = 1
					end
	
					local itemAmount = 0
	
					if itemsTable[item] then
						itemAmount = itemsTable[item]
					end
	
					return itemsTable[item] or 0
				end
			end
		end,

		giveInventoryItem = function(user_id,item,amount)
			local inventory = exports["vorp_inventory"]:vorp_inventoryApi()
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if string.sub(item, 1, string.len("wbody|")) == "wbody|" then
					local itemSplit = Functions["default-server"].striata_splitString(item,"|")
					exports.vorp_inventory:createWeapon(source, string.upper(itemSplit[2]))
					return true
				elseif item == "dinheirosujo" then
					local character = VorpCore.getUserByCharId(tonumber(user_id)).getUsedCharacter
					character.addCurrency(2, amount)
					return true
				else
					inventory.addItem(source, item, amount)
					return true
				end
			else
				--? Player Offline
				if string.sub(item, 1, string.len("wbody|")) == "wbody|" then
					local itemSplit = Functions["default-server"].striata_splitString(item,"|")
					itemSplit[2] = string.upper(itemSplit[2])
					
					local function getSteamWhereUserId(user_id)
						local infosdb = MySQL.Sync.fetchAll("SELECT identifier FROM characters WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id
						})
						if infosdb[1] then
							return infosdb[1].identifier
						end
						return false
					end

					local SvUtils = exports["vorp_inventory"]:SvUtils()
					local label = SvUtils.GenerateWeaponLabel(itemSplit[2])

					MySQL.Sync.fetchAll("INSERT INTO loadout (identifier, charidentifier, name, ammo, components, label, serial_number, custom_label ) VALUES (@identifier, @charidentifier, @name, @ammo, @components, @label, @serial_number, @custom_label);", {
						['identifier'] = getSteamWhereUserId(user_id),
						['charidentifier'] = user_id,
						['name'] = itemSplit[2],
						['ammo'] = "[]",
						['components'] = "[]",
						['label'] = label,
						['serial_number'] = SvUtils.GenerateSerialNumber(itemSplit[2]),
						['custom_label'] = label
					})
					return true
				elseif item == "dinheirosujo" then
					local moneyRows = MySQL.Sync.fetchAll("SELECT rol FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})
	
					if moneyRows[1] and moneyRows[1].rol then
						MySQL.Sync.fetchAll("UPDATE characters SET rol = @rol WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@rol"] = tonumber(moneyRows[1].rol) + amount,
						})
						return true
					else
						return false
					end
				else
					local rows =  MySQL.Sync.fetchAll("SELECT * FROM character_inventories WHERE character_id = @character_id", {
						["@character_id"] = (user_id),
					})
	
					local itemsTable = {}
	
					for row, infos in pairs(rows) do
						itemsTable[infos.item_name] = tonumber(infos.amount)
					end
	
					local currentAmount = 0
					if itemsTable[item] then
						MySQL.Sync.fetchAll("DELETE FROM character_inventories WHERE character_id = @character_id AND item_name = @item_name", {
							["@character_id"] = user_id,
							["@item_name"] = item
						})
						currentAmount = itemsTable[item]
					end
	
					MySQL.Sync.fetchAll("INSERT INTO character_inventories (character_id, item_crafted_id, amount, item_name) VALUES (@charid, @itemid, @amount ,@item_name);", {
						['charid'] = tonumber(user_id),
						['itemid'] = 0,
						['amount'] = tonumber(amount) + currentAmount,
						['item_name'] = item
					})
					return true
				end
			end
		end,

		removeInventoryItem = function(user_id,item,amount)
			if item == "" then
				return true
			end

			local inventory = exports["vorp_inventory"]:vorp_inventoryApi()
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if string.sub(item, 1, string.len("wbody|")) == "wbody|" then
					local itemSplit = Functions["default-server"].striata_splitString(item,"|")
					item = tonumber(itemSplit[3])
					exports.vorp_inventory:subWeapon(source, item)
					exports.vorp_inventory:deleteWeapon(source, item)
					TriggerClientEvent('syn_weapons:removeallammo', source)  -- syn script
					TriggerClientEvent('vorp_weapons:removeallammo', source) -- vorp
					return true
				elseif item == "dinheirosujo" then
					local character = VorpCore.getUserByCharId(tonumber(user_id)).getUsedCharacter
					if character.rol >= amount then
						character.removeCurrency(2, amount)
						return true
					else
						return false
					end
				else
					if Functions["server"].getInventoryItemAmount(user_id,item) >= amount then
						inventory.subItem(source, item, amount)
						return true
					else
						return false
					end
				end
			else
				--? Player Offline
				if string.sub(item, 1, string.len("wbody|")) == "wbody|" then
					local itemSplit = Functions["default-server"].striata_splitString(item,"|")

					MySQL.Sync.fetchAll("DELETE FROM loadout WHERE charidentifier = @charidentifier AND name = @name", {
						["@charidentifier"] = user_id,
						["@name"] = itemSplit[2]
					})
					
					return true
				elseif item == "dinheirosujo" then
					local moneyRows = MySQL.Sync.fetchAll("SELECT rol FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})
	
					if moneyRows[1] and moneyRows[1].rol and tonumber(moneyRows[1].rol) >= amount then
						MySQL.Sync.fetchAll("UPDATE characters SET rol = @rol WHERE charidentifier = @charidentifier", {
							["@charidentifier"] = user_id,
							["@rol"] = tonumber(moneyRows[1].rol) - amount,
						})
						return true
					else
						return false
					end
				else
					local rows =  MySQL.Sync.fetchAll("SELECT * FROM character_inventories WHERE character_id = @character_id", {
						["@character_id"] = (user_id),
					})
	
					local itemsTable = {}
	
					for row, infos in pairs(rows) do
						itemsTable[infos.item_name] = tonumber(infos.amount)
					end
	
					if itemsTable[item] and itemsTable[item] >= amount then
						
						MySQL.Sync.fetchAll("DELETE FROM character_inventories WHERE character_id = @character_id AND item_name = @item_name", {
							["@character_id"] = user_id,
							["@item_name"] = item
						})
	
						if (itemsTable[item] - amount) > 0 then
							MySQL.Sync.fetchAll("INSERT INTO character_inventories (character_id, item_crafted_id, amount, item_name) VALUES (@charid, @itemid, @amount ,@item_name);", {
								['charid'] = tonumber(user_id),
								['itemid'] = 0,
								['amount'] = tonumber(itemsTable[item] - amount),
								['item_name'] = item
							})
						end
						
						return true
					else
						return false
					end
				end
			end
		end,

		getInventoryWeight = function(user_id)
			local source = Functions["server"].getUserSource(user_id)

			local itens = function(_itens)
				itens = _itens
			end
			local weapon = function(_weapon)
				weapon = _weapon
			end

			itens = exports["vorp_inventory"]:getUserInventoryItems(source,itens)
			weapon = exports["vorp_inventory"]:getUserInventoryWeapons(source,weapon)

			local timeOut
			SetTimeout(1000,function()
				timeOut = true
			end)

			repeat
				Wait(1)
			until(type(itens) ~= "function" and type(weapon) ~= "function" or timeOut)
			
			if timeOut then
				return
			end

			local totalWeight = 0

			for n, infos in pairs(itens) do
				totalWeight = totalWeight + (infos.weight * infos.count)
			end
			for n, infos in pairs(weapon) do
				totalWeight = totalWeight + infos.weight
			end

			return totalWeight
		end,

		setInventoryWeight = function(user_id,weight) --? Exclusive VORP
			local source = Functions["server"].getUserSource(user_id)
			local Character = VorpCore.getUser(source).getUsedCharacter
			Character.updateInvCapacity((-1 * Character.invCapacity) + weight)
			return true
		end,

		getInventoryMaxWeight = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			return user.getUsedCharacter.invCapacity
		end,

		getItemWeight = function(item)
			if item == "" then
				return 0.0
			end
			local itemInfos = exports["vorp_inventory"]:getItemDB(item)
			if itemInfos then
				return itemInfos.weight
			else
				return 0.0
			end
		end,

		getItemName = function(item)
			if item == "" then
				return ""
			end
			
			local itemInfos = exports["vorp_inventory"]:getItemDB(item)
			if itemInfos then
				return itemInfos.label
			else
				return "Indefinido"
			end
		end,

		getItemIndex = function(item)
			return item
		end,

		giveVehicle = function(user_id,vehicle)
			local rows =  MySQL.Sync.fetchAll("SELECT identifier FROM characters WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = (user_id),
			})

			if rows[1] then
				if string.sub(vehicle, 1, string.len("horse|")) == "horse|" then
					local itemSplit = Functions["default-server"].striata_splitString(vehicle,"|")
					local queryCheck = [[
						SELECT 
							(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'kd_horses') AS t_kd_horses_exists
					]]
					local resultCheck = MySQL.Sync.fetchAll(queryCheck)
					if resultCheck[1].t_kd_horses_exists > 0 then
						MySQL.Sync.fetchAll("INSERT IGNORE INTO kd_horses(identifier,charid,model,name) VALUES(@identifier,@charid,@model,@name)", {
							["@identifier"] = rows[1].identifier,
							["@charid"] = user_id,
							["@model"] = itemSplit[2],
							["@name"] = "Galopante"
						})
					else
						MySQL.Sync.fetchAll("INSERT IGNORE INTO stables(identifier,charidentifier,modelname,name) VALUES(@identifier,@charid,@model,@name)", {
							["@identifier"] = rows[1].identifier,
							["@charid"] = user_id,
							["@model"] = itemSplit[2],
							["@name"] = "Galopante"
						})
					end
					return true
				else
					return MySQL.Sync.fetchAll("INSERT IGNORE INTO wagons(identifier,charid,model,name) VALUES(@identifier,@charid,@model,@name)", {
						["@identifier"] = rows[1].identifier,
						["@charid"] = user_id,
						["@model"] = vehicle,
						["@name"] = "Galopante"
					})
				end
			end
		end,

		removeVehicle = function(user_id,vehicle)
			if string.sub(vehicle, 1, string.len("horse|")) == "horse|" then
				local queryCheck = [[
					SELECT 
						(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'kd_horses') AS t_kd_horses_exists
				]]
				local resultCheck = MySQL.Sync.fetchAll(queryCheck)
				if resultCheck[1].t_kd_horses_exists > 0 then
					local itemSplit = Functions["default-server"].striata_splitString(vehicle,"|")
					MySQL.Sync.fetchAll("DELETE FROM kd_horses WHERE charid = @charid AND model = @model", {
						["@charid"] = user_id,
						["@model"] = itemSplit[2],
					})
				else
					local itemSplit = Functions["default-server"].striata_splitString(vehicle,"|")
					MySQL.Sync.fetchAll("DELETE FROM stables WHERE charidentifier = @charidentifier AND modelname = @modelname", {
						["@charidentifier"] = user_id,
						["@modelname"] = itemSplit[2],
					})
				end
				return true
			else
				MySQL.Sync.fetchAll("DELETE FROM wagons WHERE charid = @charid AND model = @model", {
					["@charid"] = user_id,
					["@model"] = vehicle,
				})
				return true
			end
		end,

		getUserVehicles = function(user_id)
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'kd_horses') AS t_kd_horses_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			local stablesRow = MySQL.Sync.fetchAll("SELECT * FROM stables WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = user_id
			})
			local wagonsRow = MySQL.Sync.fetchAll("SELECT * FROM wagons WHERE charid = @charid", {
				["@user_id"] = user_id
			})

			if #wagonsRow >= 1 then
				for n,vehicleInfo in pairs(wagonsRow) do
					table.insert(vehiclesInfos,
						{
							model = vehicleInfo.model,
							plate = "",
							arest = false, 
							engineHealth = 100.0, 
							bodyHealth = 100.0,
							fuel = 100.0,
							taxTime = 0,
							odometer = 0.0,
							tunning = {},
							damage = {}
						}
					)
				end
			end

			if resultCheck[1].t_kd_horses_exists > 0 then
				local horsesRows = MySQL.Sync.fetchAll("SELECT * FROM kd_horses WHERE user_id = @user_id", {
					["@user_id"] = user_id
				})

				if #horsesRows >= 1 then
					for n,vehicleInfo in pairs(horsesRows) do
						table.insert(vehiclesInfos,
							{
								model = vehicleInfo.model,
								plate = "",
								arest = false, 
								engineHealth = vehicleInfo.gear, 
								bodyHealth = 100.0,
								fuel = 100.0,
								taxTime = 0,
								odometer = 0.0,
								tunning = {},
								damage = {}
							}
						)
					end
				end
			else
				if #stablesRow >= 1 then
					for n,vehicleInfo in pairs(stablesRow) do
						table.insert(vehiclesInfos,
							{
								model = vehicleInfo.modelname,
								plate = "",
								arest = false, 
								engineHealth = vehicleInfo.gear, 
								bodyHealth = 100.0,
								fuel = 100.0,
								taxTime = 0,
								odometer = 0.0,
								tunning = {},
								damage = {}
							}
						)
					end
				end
			end
		end,

		saveOutfit = function(source,outfit)
			local currentOutfit = ""

			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})

			if #savedOutfit > 0 then
				savedOutfit = savedOutfit[1].txt
				currentOutfit = json.decode(savedOutfit)
			else
				savedOutfit = ""
				currentOutfit = outfit
				MySQL.Sync.fetchAll("REPLACE INTO striatadb(user_id,db,txt) VALUES(@user_id,@db,@txt)", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit",
					["@txt"] = json.encode(outfit)
				})
			end
			
			local rIdle = {}
			for k,v in pairs(currentOutfit) do
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
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jail') AS t_jail_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_jail_exists > 0 then
				local row = MySQL.Sync.fetchAll("SELECT time_s FROM jail WHERE characterid = @characterid", {
					["@characterid"] = (Functions["server"].getUserId(source)),
				})
				if row[1] then
					return tonumber(row[1].time_s)
				else
					return 0
				end
			end

			return 0
		end,

		setArrestPoliceTime = function(user_id,time)
			local queryCheck = [[
				SELECT 
					(SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jail') AS t_jail_exists
			]]
			local resultCheck = MySQL.Sync.fetchAll(queryCheck)

			if resultCheck[1].t_jail_exists > 0 then
				local rows =  MySQL.Sync.fetchAll("SELECT * FROM character_inventories WHERE character_id = @character_id", {
					["@character_id"] = (user_id),
				})

				if rows[1] then
					MySQL.Sync.fetchAll("REPLACE INTO jail(identifier,name,characterid,time,time_s,jaillocation) VALUES(@identifier,@name,@characterid,@time,@time_s,@jaillocation)", {
						["@identifier"] = user_id,
						["@name"] = rows[1].firstname,
						["@characterid"] = rows[1].charidentifier,
						["@time"] = os.time() + time,
						["@time_s"] = time,
						["@jaillocation"] = "sk",
					})
					return true
				end
			end

			return false
		end,

		getFines = function(user_id)
			return 0.0
		end,

		setFine = function(user_id,value)
			return Functions["server"].removeHandMoney(user_id,value)
		end,

		getUserInfo = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			if user then
				--? Player Online
				local info = {}
				info["name"] = user.getUsedCharacter.firstname
				info["lastName"] = user.getUsedCharacter.lastname
				info["age"] = user.getUsedCharacter.age
				info["document"] = user.getUsedCharacter.identifier
				info["phone"] = "000-000"
				return info
			else
				--? Player Offline
				local rows = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})
				if rows then
					local info = {}
					info["name"] = rows.firstname
					info["lastName"] = rows.lastname
					info["age"] = rows.age
					info["document"] = rows.identifier
					info["phone"] = "000-000"
					return info
				end
			end
		end,

		getHealth = function(user_id)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				return getTunnelInformation("getHealth","functions",source)
			else
				--? Player Offline
				local rows = MySQL.Sync.fetchAll("SELECT isdead FROM characters WHERE charidentifier = @charidentifier", {
					["@charidentifier"] = user_id,
				})

				if rows then
					return rows.isdead and 0 or 600
				end
			end
			return false
		end,

		setHealth = function(user_id,amount)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				getTunnelInformation("setHealth","functions",source,amount)
			else
				--? Player Offline
				if amount > 0 then
					MySQL.Sync.fetchAll("UPDATE characters SET isdead = @isdead WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@isdead"] = 0,
					})
				else
					MySQL.Sync.fetchAll("UPDATE characters SET isdead = @isdead WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
						["@isdead"] = 1,
					})
				end
			end
			return false
		end,

		getArmour = function(user_id)
			return 0.0
		end,

		setArmour = function(user_id,amount)			
			return false
		end,

		getHunger = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			if user then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudGetStatus","functions","hunger")
				else
					local status = json.decode(user.getUsedCharacter.status)
					return status.Hunger
				end
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					local row = MySQL.Sync.fetchAll("SELECT hunger FROM fx_hud WHERE charid = @charid", {
						["@charid"] = user_id,
					})

					if row and row[1] then
						return tonumber(row[1].hunger)
					end
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						return statusTable.Hunger
					end
				end
			end
		end,

		setHunger = function(user_id,amount)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudSetStatus","functions","hunger",amount)
				else
					TriggerClientEvent('vorpmetabolism:setValue', source, 'Hunger', amount)
				end
				return true
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					MySQL.Sync.fetchAll("UPDATE fx_hud SET hunger = @hunger WHERE charid = @charid", {
						["@charid"] = user_id,
						["@hunger"] = tonumber(amount),
					})
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						statusTable.Hunger = amount

						MySQL.Sync.fetchAll("UPDATE characters SET status = @status WHERE charidentifier = @charidentifier", {
							["@charid"] = user_id,
							["@status"] = json.encode(statusTable),
						})
					end
				end
				return true
			end
			
			return false
		end,
		
		getThirst = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			if user then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudGetStatus","functions","thirst")
				else
					local status = json.decode(user.getUsedCharacter.status)
					return status.Thirst
				end
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					local row = MySQL.Sync.fetchAll("SELECT thirst FROM fx_hud WHERE charid = @charid", {
						["@charid"] = user_id,
					})

					if row and row[1] then
						return tonumber(row[1].thirst)
					end
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						return statusTable.Thirst
					end
				end
			end
		end,

		setThirst = function(user_id,amount)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudSetStatus","functions","thirst",amount)
				else
					TriggerClientEvent('vorpmetabolism:setValue', source, 'Thirst', amount)
				end
				return true
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					MySQL.Sync.fetchAll("UPDATE fx_hud SET thirst = @hunger WHERE charid = @charid", {
						["@charid"] = user_id,
						["@thirst"] = tonumber(amount),
					})
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						statusTable.Thirst = amount

						MySQL.Sync.fetchAll("UPDATE characters SET status = @status WHERE charidentifier = @charidentifier", {
							["@charid"] = user_id,
							["@status"] = json.encode(statusTable),
						})
					end
				end
				return true
			end
			
			return false
		end,

		getStress = function(user_id)
			local user = VorpCore.getUserByCharId(user_id)
			if user then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudGetStatus","functions","stress")
				else
					local status = json.decode(user.getUsedCharacter.status)
					return status.Metabolism
				end
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					local row = MySQL.Sync.fetchAll("SELECT stress FROM fx_hud WHERE charid = @charid", {
						["@charid"] = user_id,
					})

					if row and row[1] then
						return tonumber(row[1].stress)
					end
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						return statusTable.Metabolism
					end
				end
			end
		end,

		setStress = function(user_id,amount)
			local source = Functions["server"].getUserSource(user_id)
			if source then
				--? Player Online
				if GetResourceState('fx-hud') == "started" then
					getTunnelInformation(user.source,"fxHudSetStatus","functions","stress",amount)
				else
					TriggerClientEvent('vorpmetabolism:setValue', source, 'Metabolism', amount)
				end
				return true
			else
				--? Player Offline
				if GetResourceState('fx-hud') == "started" then
					MySQL.Sync.fetchAll("UPDATE fx_hud SET stress = @stress WHERE charid = @charid", {
						["@charid"] = user_id,
						["@stress"] = tonumber(amount),
					})
				else
					local row = MySQL.Sync.fetchAll("SELECT status FROM characters WHERE charidentifier = @charidentifier", {
						["@charidentifier"] = user_id,
					})

					if row and row[1] then
						local statusTable = json.encode(row[1].status)
						statusTable.Metabolism = amount

						MySQL.Sync.fetchAll("UPDATE characters SET status = @status WHERE charidentifier = @charidentifier", {
							["@charid"] = user_id,
							["@status"] = json.encode(statusTable),
						})
					end
				end
				return true
			end
			
			return false
		end,
		
		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
				for configName, itemName in pairs(survivalLangs.itens) do
					exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem(itemName, function(data)
						if configName == "itemMedBag" then
							TriggerEvent("striata:survival:medBag",data.source)
						elseif configName == "itemTweezers" then
							TriggerEvent("striata:survival:useTweezers",data.source)
						elseif configName == "itemSutureKit" then
							TriggerEvent("striata:survival:useSutureKit",data.source)
						elseif configName == "itemBurnCream" then
							TriggerEvent("striata:survival:useBurnCream",data.source)
						elseif configName == "itemDefib" then
							TriggerEvent("striata:survival:useDefib",data.source)
						elseif configName == "itemStretcher" then
							TriggerEvent("striata:survival:useStretcher",data.source)
						elseif configName == "itemShroud" then
							TriggerEvent("striata:survival:shroud",data.source)
						end

						TriggerClientEvent("vorpinventory:updateinventory", data.source)
					end)
				end
			end

			if Config.resources["striata_advancedfuel"] then
				local advancedFuelConfig, advancedFuelLangs = exports['striata_resources']:striata_advancedFuel_config()

				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("galao-gasoline", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","gasoline")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("galao-diesel", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","diesel")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("galao-gas", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","gas")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("galao-ethanol", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","ethanol")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("galao-avGas", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","avGas")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				-- exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("bateria", function(data)
				-- 	TriggerClientEvent("striata:fuel:refuel",data.source,"battery","energy")
				-- 	TriggerClientEvent("vorpinventory:updateinventory", data.source)
				-- end)
				
				exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("sacocomcarvao", function(data)
					TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","coal")	
					TriggerClientEvent("vorpinventory:updateinventory", data.source)
				end)
				
				exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem("balde-animalFeed", function(data)
					TriggerClientEvent("striata:fuel:refuel",data.source,"gallon","animalFeed")	
					TriggerClientEvent("vorpinventory:updateinventory", data.source)	
				end)
			end

			if Config.otherResources["striata_backpack"] then
				local backpackConfig, backpackLangs = exports['striata_resources']:striata_backpack_config()
				if backpackConfig then
					for n,infos in pairs(backpackConfig.backpackList) do
						exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem(infos.name, function(data)
							TriggerEvent("striata_backpack:useBackpack",data.source,infos.name)
							TriggerClientEvent("vorpinventory:updateinventory", data.source)
						end)
					end
				end
			end

			if Config.otherResources["striata_medicalsystem"] then
				local medicalSystemConfig, medicalSystemLangs = exports['striata_resources']:striata_medicalSystem_config()
				if medicalSystemConfig then
					for n,infos in pairs(medicalSystemConfig.healItens) do
						exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem(infos.itemName, function(data)
							TriggerEvent("striata:medicalSystem:useHealItem",data.source,infos.itemName)
							TriggerClientEvent("vorpinventory:updateinventory", data.source)
						end)
					end
				end
			end

			if Config.otherResources["striata_phonograph"] then
				local phonographConfig, phonographLangs = exports['striata_resources']:striata_phonograph_config()
				if phonographConfig then
					exports["vorp_inventory"]:vorp_inventoryApi().RegisterUsableItem(phonographConfig.diskItem, function(data)
						TriggerEvent("striata_phonograph:useDisk",data.source,data.item.metadata)
						TriggerClientEvent("vorpinventory:updateinventory", data.source)
					end)
				end
			end
		end,

		checkHomeAcess = function(source,user_id,homeName)
			TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
			return false
		end,

		getWhiteListStatus = function(user_id)
			local result = MySQL.Sync.fetchAll('SELECT status FROM whitelist WHERE identifier = ?', { user_id })
			if result[1] then
				if result[1].status and (result[1].status == 1 or result[1].status == "1" or result[1].status == true) then
					return true
				end
			end
			return false
		end,

		changeWhiteListStatus = function(user_id,status)
			if status then
				VorpCore.Whitelist.whitelistUser(user_id)
				return true
			else
				VorpCore.Whitelist.unWhitelistUser(user_id)
				return true
			end
		end,
		
		getBanStatus = function(user_id)
			local rows =  MySQL.Sync.fetchAll("SELECT identifier FROM characters WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = (user_id),
			})

			if rows[1] then
				local rows2 = MySQL.Sync.fetchAll("SELECT banned FROM users WHERE identifier = @identifier", {
					["@identifier"] = rows[1].identifier
				})
				return rows2 and rows2[1] and rows2[1].banned
			end
			return nil
		end,

		setBanStatus = function(user_id,status,reason)
			local source = Functions["server"].getUserSource(user_id)
			if status and source then
				DropPlayer(source, reason)
			end

			local source = Functions["server"].getUserSource(user_id)
			if status and source then
				DropPlayer(source, reason)
			end

			local rows =  MySQL.Sync.fetchAll("SELECT identifier FROM characters WHERE charidentifier = @charidentifier", {
				["@charidentifier"] = (user_id),
			})

			if rows[1] then
				MySQL.Sync.fetchAll("UPDATE users SET banned = @banned WHERE identifier = @identifier", {
					["@identifier"] = rows[1].identifier,
					["@banned"] = status,
				})

				return true
			end

			return false
		end,

		checkPlayerIsDiscordMember = function(user_id,discordId)
			if Config.resources["striata_discordbot"] then
				return exports["striata_resources"]:checkIsMember(user_id,discordId)
			else
				return false
			end
		end
	}
}

Events.VORP = {
	client = {
		playerSpawn = "custom:playerSpawned",
		groupChange = {"vorp:playerGroupChange","vorp:playerJobChange","vorp:playerJobGradeChange"}
	},
	server = {
		playerSpawn = "custom:playerSpawned",
		groupChange = {"vorp:playerGroupChange","vorp:playerJobChange","vorp:playerJobGradeChange"}
	}
}
if IsDuplicityVersion() then --? Server only
	RegisterServerEvent("striata_resources:serverReady")
	AddEventHandler("striata_resources:serverReady",function()
		if CurrentFrameWork == "VORP" then
			RegisterServerEvent("vorp:SelectedCharacter")
			AddEventHandler("vorp:SelectedCharacter", function(source,character)
				TriggerEvent("custom:playerSpawned",character.charIdentifier,source,false)
				TriggerClientEvent("custom:playerSpawned",source)
			end)

			for n,event in pairs(Events["server"].groupChange) do
				RegisterServerEvent(event)
				AddEventHandler(event, function(source,newJob)
					TriggerClientEvent(event,source,newJob)
				end)
			end
		end
	end)
end

Functions.custom = {
	client = {
		--- @param return table
		getSharedObject = function()
			return {}
		end,

		--- @param script string
		--- @param functionName string
		--- @param return result
		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		--- @param text string
		--- @param time integer
		--- @param return boolean
		request = function(text, time)
			return false
		end,

		--- @param text string
		--- @param input string #placeholder
		--- @param return string
		textInput = function(text, input)
			return ""
		end,

		--- @param return table:{ ["weapon_name"] = { ammo = integer },... }
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

		--- @param weapons string
		--- @param clearBefore boolean #Remove all weapons before add
		--- @param return boolean
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
			
			return true
		end,

		--- @param return table: {model # player ped model name or modelhash #player ped model hash, [integer: #clothing index from 1 to 20] = {DrawableVariation, TextureVariation, PaletteVariation},... [string: "p"..integer #clothing prop index from 1 to 10] = {DrawableVariation, TextureVariation, PaletteVariation} }
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

		--- @param outfit table: {model # player ped model name or modelhash #player ped model hash, [integer: #clothing index from 1 to 20] = {DrawableVariation, TextureVariation, PaletteVariation},... [string: "p"..integer #clothing prop index from 1 to 10] = {DrawableVariation, TextureVariation, PaletteVariation} }
		--- @param return boolean, integer: #Player Ped Model Hash
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

		--- @param toggle boolean
		--- @param return boolean
		setPlayerHandcuffed = function(toggle)
			return false
		end,

		--- @param x float #coordinate x
		--- @param y float #coordinate y
		--- @param z float #coordinate z
		--- @param return boolean
		teleportPlayer = function(x,y,z)
			SetEntityCoords(PlayerPedId(), vector3(x,y,z), false, false, false, false)

			return true
		end,

		--- @param event string
		--- @param sound string
		--- @param volume integer
		playSoundByScript = function(event,sound,volume)
			TriggerEvent(event,sound,volume)
		end,

		--- @param dict string
		--- @param name string
		playSoundByGame = function(dict,name)
			PlaySoundFrontend(-1,dict,name,false)
		end,

		--- @param radius integer
		--- @param return table: { [integer #vehicle id] = integer #distance,... }
		getNearestVehicles = function(radius)
			local r = {}
			local coords = GetEntityCoords(PlayerPedId())
		
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
		
			for _,veh in pairs(vehs) do
				local coordsVeh = GetEntityCoords(veh)
				local distance = #(coords - coordsVeh)
				if distance <= radius then
					r[veh] = distance
				end
			end

			return r
		end,

		--- @param radius integer
		--- @param return integer #vehicle id
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
		
		--- @param radius integer
		--- @param return table: { [integer #player source] = integer #distance,... }
		getNearestPlayers = function(radius)
			local allPlayers = GetActivePlayers()
			local players = {}
			local currentPedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId()))
			for n,playerId in pairs(allPlayers) do
				if GetPlayerServerId(playerId) ~= currentPedId then
					local player = GetPlayerPed(playerId)
					local coords = GetEntityCoords(PlayerPedId())
					local pedCoords = GetEntityCoords(player)
					local distance = #(pedCoords - coords)
					players[GetPlayerServerId(playerId)] = distance
				end
			end
			return players
		end,

		--- @param radius integer
		--- @param return integer or false #player source
		getNearestPlayer = function(radius)			
			for player, distance in pairs(Functions["client"]:getNearestPlayers(radius)) do
				if distance <= radius then
					return player
				end
			end
			return false
		end,

		--- @param return boolean
		killGod = function()
			TransitionFromBlurred(1000)
			local ped = PlayerPedId()
			if GetEntityHealth(ped) < 101 or IsEntityDead(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
			end
			ClearPedBloodDamage(ped)
			SetEntityInvincible(ped,false)
			Functions["client"].setHealth(120)
			ClearPedTasks(ped)
			ClearPedSecondaryTask(ped)
			return true
		end,
	
		--- @param return boolean
		setHealth = function(health)
			SetEntityHealth(PlayerPedId(),tonumber(health))
			return true
		end,
		
		--- @param x float #coordinate x
		--- @param y float #coordinate y
		--- @param z float #coordinate z
		--- @param idtype integer
		--- @param idcolor integer
		--- @param text string
		--- @param scale integer
		--- @param route boolean
		--- @param return integer #blip id
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
		
		--- @param blipId integer #blip id
		removeBlip = function(blipId)
			RemoveBlip(id)
		end,
		--- @param ex table: {model # player ped model name or modelhash #player ped model hash, [integer: #clothing index from 1 to 20] = {DrawableVariation, TextureVariation, PaletteVariation},... [string: "p"..integer #clothing prop index from 1 to 10] = {DrawableVariation, TextureVariation, PaletteVariation} }

		--- @param models table: {1234576789,-987654321,...}
		--- @param configuration table: { options = table: {{event = string, label = string, tunnel = string},...}, distance = float }
		AddTargetModel = function(models,configuration)
			return false
		end
	},

	server = {
		--- @param return table
		getSharedObject = function()
			return {}
		end,

		--- @param script string
		--- @param functionName string
		--- @param return result
		exports = function(script,functionName,...)
			return exports[script][functionName](...)
		end,

		--- @param source integer
		--- @param identifiers string
		--- @param return integer or string # user_id or steam ex: "steam:1100001100a1b2c"
		getUserIdByIdentifiers = function(source,identifiers)
			if source and not identifiers then
				identifiers = GetPlayerIdentifiers(source)
			end

			local steam

			for n,identifier in pairs(identifiers) do
				if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
					steam = identifier
					break
				end
			end

			return steam
		end,

		--- @param source integer # player source
		--- @param return integer or string # player inique id
		getUserId = function(source)
			return ""
		end,

		--- @param user_id integer or string # player inique id
		--- @param return integer # player source
		getUserSource = function(user_id)
			return 0
		end,

		--- @param return table: { [integer or string # player unique id] = integer # player source,... }
		getUsers = function()
			local users = {}
			for k,v in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(v))
				if user_id then
					users[user_id] = v
				end
			end
			return users
		end,

		--- @param perm string
		--- @param return table: { [integer] = integer or string # player unique id,... }
		getUsersByPermission = function(perm)
			local users = {}
			for n,source in pairs(GetPlayers()) do
				local user_id = Functions["server"].getUserId(tonumber(source))
				if Functions["server"].hasPermission(user_id,perm) then
					table.insert(users,user_id)
				end
			end
			return users
		end,

		--- @param user_id integer or string
		--- @param perm string
		--- @param return bloolean
		hasPermission = function(user_id, perm)
			return false
		end,

		--- @param user_id integer or string
		--- @param return table: { [string # group, job or vip] = { ["hierarchyName"] = string or number } }
		getUserGroups = function(user_id)
			return {}
		end,

		--- @param return table: { [string # group, job or vip] = { ["user_id"] = integer or string ,["hierarchyName"] = integer or string } }
		getAllUserGroups = function()
			local allUserGroups = {}
			return allUserGroups
		end,
		
		--- @param user_id integer or string
		--- @param group string
		--- @param return bloolean
		addUserGroup = function(user_id,group)
			return false
		end,

		--- @param user_id integer or string
		--- @param group string
		--- @param return bloolean
		removeUserGroup = function(user_id,group)
			return false
		end,

		--- @param user_id integer or string
		--- @param amount integer
		--- @param return bloolean
		giveHandMoney = function(user_id, amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param amount integer
		--- @param return bloolean
		removeHandMoney = function(user_id, amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return integer
		getHandMoney = function(user_id)
			return 0
		end,

		--- @param user_id integer or string
		--- @param amount integer
		--- @param return bloolean
		giveBankMoney = function(user_id, amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param amount integer
		--- @param return bloolean
		removeBankMoney = function(user_id, amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return integer
		getBankMoney = function(user_id)
			return 0
		end,

		--- @param user_id integer or string
		--- @param return table: { [string # item name] = integer # item amount,... }
		getInventoryItems = function(user_id)
			return {}
		end,

		--- @param user_id integer or string
		--- @param item string
		--- @param return integer
		getInventoryItemAmount = function(user_id,item)
			return 0
		end,

		--- @param user_id integer or string
		--- @param item string
		--- @param amount integer
		--- @param return bloolean
		giveInventoryItem = function(user_id,item,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param item string
		--- @param amount integer
		--- @param return bloolean
		removeInventoryItem = function(user_id,item,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getInventoryWeight = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param return float
		getInventoryMaxWeight = function(user_id)
			return 0.0
		end,

		--- @param item string
		--- @param return float
		getItemWeight = function(item)
			return 0.0
		end,

		--- @param item string
		--- @param return string
		getItemName = function(item)
			return ""
		end,

		--- @param item string
		--- @param return string # Item image name without ".png"
		getItemIndex = function(item)
			return ""
		end,

		--- @param user_id integer or string
		--- @param vehicle string
		--- @param return bloolean
		giveVehicle = function(user_id,vehicle)
			return false
		end,

		--- @param user_id integer or string
		--- @param vehicle string
		--- @param return bloolean
		removeVehicle = function(user_id,vehicle)
			return false
		end,

		--- @param user_id integer or string
		--- @param return table: { { model = string, plate = string, arest = boolean, engineHealth = float, bodyHealth = float, fuel = float, taxTime = timestump, odometer = float, tunning = table: { wheeltype = integer, extracolor = table: { integer, integer }, xenoncolor = integer, customPcolor = table: { integer, integer, integer }, damage = float, color = table: { integer, integer }, neon = bloolean, model = string, mods = table: { integer = table: { variation = bloolean, mod = -1 or 0 },... }, smokecolor = table: { integer, integer, integer }, bulletProofTyres = integer, customScolor = table: { integer, integer, integer }, vehicle = integer, scolortype = string, plateindex = integer, windowtint = bloolean, neoncolor = table: { integer, integer, integer }, pcolortype = bloolean }, damage = table: { doors = table: { integer #index = boolean # status,... }, windows =  table: { integer #index = boolean # status,... }, tyres = table: { integer #index = boolean # status,... } } },... }
		getUserVehicles = function(user_id)
			return {}
		end,

		--- @param source integer
		--- @param outfit table: {model # player ped model name or modelhash #player ped model hash, [integer: #clothing index from 1 to 20] = {DrawableVariation, TextureVariation, PaletteVariation},... [string: "p"..integer #clothing prop index from 1 to 10] = {DrawableVariation, TextureVariation, PaletteVariation} }
		--- @param return table: {model # player ped model name or modelhash #player ped model hash, [integer: #clothing index from 1 to 20] = {DrawableVariation, TextureVariation, PaletteVariation},... [string: "p"..integer #clothing prop index from 1 to 10] = {DrawableVariation, TextureVariation, PaletteVariation} }
		saveOutfit = function(source,outfit)
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

		--- @param source integer
		--- @param return boolean
		removeOutfit = function(source)
			local savedOutfit = MySQL.Sync.fetchAll("SELECT txt FROM striatadb WHERE user_id = @user_id AND db = @db", {
				["@user_id"] = (Functions["server"].getUserId(source)),
				["@db"] = "beforePrisonOutfit"
			})
			if #savedOutfit > 0 then
				savedOutfit = json.decode(savedOutfit[1].txt) or {}
				savedOutfit.modelhash = nil
				TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",savedOutfit)

				return MySQL.Sync.fetchAll("DELETE FROM striatadb WHERE user_id = @user_id AND db = @db", {
					["@user_id"] = Functions["server"].getUserId(source),
					["@db"] = "beforePrisonOutfit"
				})
			end
		end,

		--- @param user_id integer or string
		--- @param return integer
		getArrestPoliceTime = function(user_id)
			return 0
		end,

		--- @param user_id integer or string
		--- @param time integer
		--- @param return boolean
		setArrestPoliceTime = function(user_id,time)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getFines = function(user_id)
			return 0.0
		end,

		
		--- @param user_id integer or string
		--- @param value float
		--- @param return boolean
		setFine = function(user_id,value)
			return false
		end,

		--- @param user_id integer or string
		--- @param return table: { name = string, lastName = string, age = integer, document = string, phone = string }
		getUserInfo = function(user_id)
			return {}
		end,

		--- @param user_id integer or string
		--- @param return float
		getHealth = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param amount float
		--- @param return bloolean
		setHealth = function(user_id,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getArmour = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param amount float
		--- @param return bloolean
		setArmour = function(user_id,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getHunger = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param amount float
		--- @param return bloolean
		setHunger = function(user_id,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getThirst = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param amount float
		--- @param return bloolean
		setThirst = function(user_id,amount)
			return false
		end,

		--- @param user_id integer or string
		--- @param return float
		getStress = function(user_id)
			return 0.0
		end,

		--- @param user_id integer or string
		--- @param amount float
		--- @param return bloolean
		setStress = function(user_id,amount)
			return false
		end,

		CreateUseableItens = function()
			if Config.resources["striata_survival"] then
				local survivalConfig, survivalLangs = exports['striata_resources']:striata_survival_config()
			end

			if Config.resources["striata_advancedfuel"] then
				local advancedFuelConfig, advancedFuelLangs = exports['striata_resources']:striata_advancedFuel_config()

				-- "galao-gasoline" --? fivem
				-- "galao-diesel" --? fivem
				-- "galao-gas" --? fivem
				-- "galao-ethanol" --? fivem
				-- "galao-avGas" --? fivem
				-- "bateria" --? fivem / redm
				-- "sacocomcarvao" --? redm
				-- "balde-animalfeed" --? redm
			end
		end,

		--- @param source integer
		--- @param user_id integer or string
		--- @param homeName string
		--- @param return bloolean
		checkHomeAcess = function(source,user_id,homeName)
			TriggerClientEvent("Notify",source,Config["notifysTypes"].denied,"Você não tem acesso à essa residência.",4500)
			return false
		end,

		--- @param user_id integer or string
		--- @param return bloolean
		getWhiteListStatus = function(user_id)
			return false
		end,

		--- @param user_id integer or string
		--- @param status bloolean
		--- @param return bloolean
		changeWhiteListStatus = function(user_id,status)
			return false
		end,
		
		--- @param user_id integer or string
		--- @param return bloolean
		getBanStatus = function(user_id)
			return false
		end,

		--- @param user_id integer or string
		--- @param status bloolean
		--- @param reason string
		--- @param return bloolean
		setBanStatus = function(user_id,status,reason)
			local source = Functions["server"].getUserSource(user_id)
			if status and source then
				DropPlayer(source, reason)
			end
			return false
		end,

		--- @param user_id integer or string
		--- @param discordId number of string
		--- @param return bloolean
		checkPlayerIsDiscordMember = function(user_id,discordId)
			if Config.resources["striata_discordbot"] then
				return exports["striata_resources"]:checkIsMember(user_id,discordId)
			else
				return false
			end
		end
	}
}
Events.custom = {
	client = {
		playerSpawn = "custom:playerSpawned",
		groupChange = {"custom:playerGroupChange","custom:playerJobChange","custom:playerJobGradeChange"}
	},
	server = {
		playerSpawn = "custom:playerSpawned",
		groupChange = {"custom:playerGroupChange","custom:playerJobChange","custom:playerJobGradeChange"}
	}
}

exports("executeFunction",function(duplicityVersion,functionName,...)
	return Functions[duplicityVersion][functionName](...)
end)