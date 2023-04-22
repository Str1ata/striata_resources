Functions = {}
Events = {}

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

        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
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

        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
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

        hasPermission = function(user_id, perm)
            return vRP.hasPermission(user_id, perm)
        end,

        getUserGroups = function(user_id)
            return vRP.getUserGroups(user_id)
        end,

        addUserGroup = function(user_id,group)
            return vRP.addUserGroup(user_id,group)
        end,

        removeUserGroup = function(user_id,group)
            if vRP.getUserSource(user_id) then
                return vRP.removeUserGroup(user_id,group)
            else
                local dataTable = json.decode(vRP.getUData(user_id, "vRP:datatable") or {})
                if dataTable and dataTable.groups then
                    if dataTable.groups[group] then
                        dataTable.groups[group] = nil
                        return vRP._setUData(user_id, "vRP:datatable", json.encode(dataTable))
                    end
                end
            end
        end,

        textInput = function(source,text, input)
            return vRP.prompt(source,text, input)
        end,

        giveBankMoney = function(user_id, amount)
            return vRP.giveBankMoney(user_id,amount)
        end,

        removeBankMoney = function(user_id, amount)
            return vRP.tryFullPayment(user_id,amount)
        end,

        getInventoryItemAmount = function(user_id,item)
            return vRP.getInventoryItemAmount(user_id,item)
        end,

        giveInventoryItem = function(user_id,item,amount)
            return vRP.giveInventoryItem(user_id,item,amount,true)
        end,

        removeInventoryItem = function(user_id,item,amount)
            return vRP.tryGetInventoryItem(user_id,item,amount,true)
        end,

        getInventoryWeight = function(user_id)
            return vRP.getInventoryWeight(user_id)
        end,

        getInventoryMaxWeight = function(user_id)
            return vRP.getInventoryMaxWeight(user_id)
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
                print(json.encode(identity))
                info["name"] = identity.name
                info["lastName"] = identity.firstname
                info["age"] = identity.age
                info["document"] = identity.registration
                info["phone"] = identity.phone
                print(json.encode(info))
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

        setHunger = function(user_id,amount)
            vRP.setHunger(parseInt(user_id),amount)
        end,

        setThirst = function(user_id,amount)
            vRP.setThirst(parseInt(user_id),amount)
        end,
    }
    
}
Events.vRP = {
    client = {
        playerSpawn = "playerSpawned"
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
        
        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
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
        end
    },

    server = {
        getSharedObject = function()
            return exports['es_extended']:getSharedObject()
        end,

        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
        end,

        getUserId = function(source)
            return ESX.GetPlayerFromId(source).identifier
        end,

        getUserSource = function(user_id)
            return ESX.GetPlayerFromIdentifier(user_id).playerId
        end,

        getUsers = function()
            local users = {}
            for k,v in pairs(ESX.GetPlayers()) do
                users[ESX.GetPlayerFromId(v).identifier] = v
            end
            return users
        end,

        hasPermission = function(user_id,perm)
            if ESX.GetPlayerFromId(ESX.GetPlayerFromIdentifier(user_id).playerId).job.name == perm or ESX.GetPlayerFromId(ESX.GetPlayerFromIdentifier(user_id).playerId).group == perm then
                return true
            else
                return false
            end
        end,

        getUserGroups = function(user_id)
            return ESX.GetPlayerFromId(ESX.GetPlayerFromIdentifier(user_id).playerId).job
        end,
        
        addUserGroup = function(user_id,group)
            return ESX.GetPlayerFromIdentifier(user_id).setJob(group,1)
        end,

        removeUserGroup = function(user_id,group)
            local xplayer = ESX.GetPlayerFromIdentifier(user_id)
            if xplayer then
                return xplayer.setJob("unemployed", 0)
            else
                return MySQL.Sync.fetchAll('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, 0, user_id})
            end
        end,

        giveBankMoney = function(user_id, amount)
            return ESX.GetPlayerFromIdentifier(user_id).addMoney(amount)
        end,

        removeBankMoney = function(user_id, amount)
            return ESX.GetPlayerFromIdentifier(user_id).removeAccountMoney('bank', amount)
        end,

        getInventoryItemAmount = function(user_id,item)
            if ESX.GetPlayerFromIdentifier(user_id).getInventoryItem(item) then
                return (ESX.GetPlayerFromIdentifier(user_id).getInventoryItem(item).count)
            else
                return 0
            end
        end,

        giveInventoryItem = function(user_id,item,amount)
            return ESX.GetPlayerFromIdentifier(user_id).addInventoryItem(item,amount)
        end,

        removeInventoryItem = function(user_id,item,amount)
            return ESX.GetPlayerFromIdentifier(user_id).removeInventoryItem(item,amount)
        end,

        getInventoryWeight = function(user_id)
            return ESX.GetPlayerFromIdentifier(user_id).weight
        end,

        getInventoryMaxWeight = function(user_id)
            return ESX.GetPlayerFromIdentifier(user_id).maxWeight
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
            TriggerClientEvent("striata_resources:duplicityClientVersion",ESX.GetPlayerFromIdentifier(user_id).playerId,eventCallBackName,"exports",{'esx_vehicleshop',"GeneratePlate"})
        
            
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
                TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",{savedOutfit})

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
                player = json.decode(playerInfos[1])
                info["name"] = player.firstname
                info["lastName"] = player.lastname
                info["age"] = player.dateofbirth
                info["document"] = user_id
                info["phone"] = player.phone_number
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

        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
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
            return keyboard.cb
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
        end
    },

    server = {

        getSharedObject = function()
            return exports['qb-core']:GetCoreObject()
        end,

        exports = function(...)
            local args = {...}
            return exports[args[1]][args[2]](args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])
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

        giveBankMoney = function(user_id, amount)
            local player = QBCore.Functions.GetPlayerByCitizenId(user_id)
            if player then
                return player.Functions.AddMoney('bank', amount, "Bank depost")
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
                local itemInfo player.Functions.GetItemByName(item)
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
            return QBCore.Shared.Items[item].name
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
                TriggerClientEvent("striata_resources:duplicityClientVersion",source,false,"setOutfit",{savedOutfit})

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