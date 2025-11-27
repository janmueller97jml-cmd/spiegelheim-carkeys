lockStatus = {
    Locked = 2,
    Unlocked = 1
}

-- create key for vehicle after purchase
function buyVehicle(vehicle, plate, count, database)
    local data = {}
    local playerPed = PlayerPedId()
    
    if DoesEntityExist(vehicle) then
        data.vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    end

    data.database = database or Config.DefaultDatabase
    data.plate = plate
    data.vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle) or vehicleProps.model))
    data.count = count

    ESX.TriggerServerCallback('mx_carkeys:callback:buyVehicle', function(gotItem)
        if gotItem then
            if loaded_ox then
                if not Config.Metadata.hidePlate then
                    carKeysPlate = Translate('vehicle_plate')
                end
                
                if not Config.Metadata.hideModel then
                    carKeysModel = Translate('vehicle_model')
                end
                
                if not Config.Metadata.hideLockID then
                    carKeysLockID = Translate('vehicle_lockID')
                end
        
                ox_inventory:displayMetadata({
                    carKeysPlate = carKeysPlate,
                    carKeysModel = carKeysModel,
                    carKeysLockID = carKeysLockID
                })
            end

            Notify.Send('Car Key', Translate('received_key', vehicleModel), 3000, Notify.Type['got_key_for_vehicle'])
        end
    end, data)
end
RegisterNetEvent("mx_carkeys:client:buyVehicle", buyVehicle)
exports("buyVehicle", buyVehicle)

-- give a carKey
function giveCarKey(vehicle, plate, count, blankKey)
    local data = {}
    local playerPed = PlayerPedId()
    
    if DoesEntityExist(vehicle) then
        data.vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    end
    
    data.plate = plate
    data.vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle) or vehicleProps.model))
    data.count = count
    data.blankKey = blankKey

    ESX.TriggerServerCallback('mx_carkeys:callback:giveCarKey', function(callback)
        if callback == 'no_blank_key' then
            Notify.Send('Car Keys', Translate('no_blank_key'), 3000, Notify.Type['no_blank_key'])
        end

        if callback then
            if loaded_ox then
                if not Config.Metadata.hidePlate then
                    carKeysPlate = Translate('vehicle_plate')
                end
                
                if not Config.Metadata.hideModel then
                    carKeysModel = Translate('vehicle_model')
                end
                
                if not Config.Metadata.hideLockID then
                    carKeysLockID = Translate('vehicle_lockID')
                end
        
                ox_inventory:displayMetadata({
                    carKeysPlate = carKeysPlate,
                    carKeysModel = carKeysModel,
                    carKeysLockID = carKeysLockID
                })
            end
        end
    end, data)
end
RegisterNetEvent("mx_carkeys:client:giveCarKey", giveCarKey)
exports("giveCarKey", giveCarKey)

-- temporary key
function createTempKey(vehicle, plate, count)
    local data = {}

    data.vehicle = vehicle
    
    if data.vehicle then
        data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle)
        data.vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(data.vehicleProps.model))
    end

    data.plate = plate
    data.count = count

    ESX.TriggerServerCallback('mx_carkeys:callback:createTempKey', function(callback)
        if Config.DebugLevel == 2 or Config.DebugLevel == 3 then
            print(callback)
        end
    end, data)
end
RegisterNetEvent("mx_carkeys:client:createTempKey", createTempKey)
exports('createTempKey', createTempKey)

-- check if vehicle key is in players inventory
function hasVehicleKey(vehicle)
    local data = {}
    local isThatKeyValid = nil
    
    data.vehicle = vehicle

    if not data.vehicle then
        local playerPed = PlayerPedId()
        data.vehicle = GetVehiclePedIsIn(playerPed)
    end

    if data.vehicle then
        data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle) 
    end
    
    if data.vehicleProps then
        local isKeyValid, playerJob = lib.callback.await('mx_carkeys:callback:checkIsKeyValid', false, data) 
    
        while isThatKeyValid == nil do 
            Wait(1)
        end

        return isThatKeyValid
    else
        return 'error'
    end
end
exports('hasVehicleKey', hasVehicleKey)

-- remove key
function removeVehicleKey(vehicle)
    local data = {}

    data.vehicle = vehicle

    if not data.vehicle then
        error('no vehicle parameter given. vehicle must be set')
        return 'error'
    end

    if data.vehicle then
        data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle) 
    end

    if data.vehicleProps then
        CreateThread(function()
            lib.callback.await('mx_carkeys:callback:removeVehicleKey', false, data) 
        end)
    end
end
exports('removeVehicleKey', removeVehicleKey)

function lockVehicle(vehicle, lockedStatus)
    if lockedStatus then
		SetVehicleDoorsShut(vehicle, false)
        SetVehicleDoorsLocked(vehicle, lockStatus.Locked)

        if Config.PlayLockSound then
            PlaySoundFromEntity(-1, "Remote_Control_Close", vehicle, "PI_Menu_Sounds", 1, 0)
        end
    else
        SetVehicleDoorsLocked(vehicle, lockStatus.Unlocked)
		
        if Config.PlayLockSound then
            PlaySoundFromEntity(-1, "Remote_Control_Open", vehicle, "PI_Menu_Sounds", 1, 0) 
        end
    end
end

function vehicleEffects(vehicle, lockedStatus)
    if lockedStatus then
		PlayVehicleDoorCloseSound(vehicle, 0)

        CreateThread(function()
            local _, lightState, highbeamState = GetVehicleLightsState(vehicle)

            if lightState then
                SetVehicleLights(vehicle, 1)
                Wait(200)
            end

            SetVehicleLights(vehicle, 2)

            Wait(200)
            SetVehicleLights(vehicle, 1)

            Wait(200)
            SetVehicleLights(vehicle, 0)
        end)
    else
		PlayVehicleDoorOpenSound(vehicle, 0)

        CreateThread(function()
			local _, lightState, highbeamState = GetVehicleLightsState(vehicle)

			if lightState then
				SetVehicleLights(vehicle, 1)
				Wait(100)
			end

			SetVehicleLights(vehicle, 2)
            
            Wait(75)
            SetVehicleLights(vehicle, 1)

            Wait(75)
            SetVehicleLights(vehicle, 2)

			Wait(200)
			SetVehicleLights(vehicle, 0)
		end)
    end
end

function lockAnimation()
    CreateThread(function()
        RequestAnimDict("anim@mp_player_intmenu@key_fob@")
        while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
            Wait(0)
        end
        
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        RemoveAnimDict("anim@mp_player_intmenu@key_fob@")
    end)
end

-- checks if player has a matching key
function checkLockPossibility(vehicle, lockedStatus, lockpick)
    local data = {}
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    data.vehicle = vehicle
    local vehicleModel = GetEntityModel(data.vehicle)
    local vehicleCoords = GetEntityCoords(data.vehicle)
    data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
    local vehicleClass = GetVehicleClassFromName(vehicleModel)
    local distance = #(playerPos - vehicleCoords)

    if lockedStatus == nil then
		lockedStatus = GetVehicleDoorLockStatus(data.vehicle) ~= lockStatus.Locked
	end

    if distance <= Config.LockDistance then
        if Config.AdminKey.enabled then
            local isValidGroup, hasKey = lib.callback.await('mx_carkeys:callback:getAdminKey', false)

            if isValidGroup and hasKey then
                if table.contains(Config.AdminKey.vehicles, vehicleModel) then
                    if NetworkHasControlOfEntity(data.vehicle) then
                        lockVehicle(data.vehicle, lockedStatus)
                    else
                        TriggerServerEvent("mx_carkeys:server:lockVehicle", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
                    end
        
                    TriggerServerEvent("mx_carkeys:server:vehicleEffects", NetworkGetNetworkIdFromEntity(vehicle), lockedStatus)
        
                    if not IsPedInAnyVehicle(playerPed) then
                        lockAnimation()
                    end
        
                    vehicleAlarm(data.vehicle, false)
        
                    if lockedStatus then
                        Notify.Send('Car Key', Translate('vehicle_locked'), 3000, Notify.Type['vehicle_locked'])
                    else
                        Notify.Send('Car Key', Translate('vehicle_unlocked'), 3000, Notify.Type['vehicle_unlocked'])
                    end

                    if Config.AdvancedParking.enabled then
                        exports[Config.AdvancedParking.resourceName]:UpdateVehicle(data.vehicle)
                    end
                    return
                end
            end
        end

        local isKeyValid, playerJob = lib.callback.await('mx_carkeys:callback:checkIsKeyValid', false, data)               
            
        if Config.LockBlacklist.vehicleClasses[vehicleClass] == false or Config.LockBlacklist.vehicleModels[vehicleModel] == false then

            if IsWhitelistVehicle(data.vehicleProps.plate, vehicleModel) and Config.WhitelistVehicles.allowLocking then
                if NetworkHasControlOfEntity(data.vehicle) then
                    lockVehicle(data.vehicle, lockedStatus)
                else
                    TriggerServerEvent("mx_carkeys:server:lockVehicle", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
                end

                TriggerServerEvent("mx_carkeys:server:vehicleEffects", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
    
                if not IsPedInAnyVehicle(playerPed) then
                    lockAnimation()
                end

                vehicleAlarm(data.vehicle, false)
    
                if lockedStatus then
                    Notify.Send('Car Key', Translate('vehicle_locked'), 3000, Notify.Type['vehicle_locked'])
                else
                    Notify.Send('Car Key', Translate('vehicle_unlocked'), 3000, Notify.Type['vehicle_unlocked'])
                end

                if Config.AdvancedParking.enabled then
                    exports[Config.AdvancedParking.resourceName]:UpdateVehicle(data.vehicle)
                end
            elseif IsJobVehicle(playerJob.name, data.vehicleProps.plate, vehicleModel) then
                if NetworkHasControlOfEntity(data.vehicle) then
                    lockVehicle(data.vehicle, lockedStatus)
                else
                    TriggerServerEvent("mx_carkeys:server:lockVehicle", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
                end
                
                TriggerServerEvent("mx_carkeys:server:vehicleEffects", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
                
                if not IsPedInAnyVehicle(playerPed) then
                    lockAnimation()
                end

                vehicleAlarm(data.vehicle, false)
    
                if lockedStatus then
                    Notify.Send('Car Key', Translate('vehicle_locked'), 3000, Notify.Type['vehicle_locked'])
                else
                    Notify.Send('Car Key', Translate('vehicle_unlocked'), 3000, Notify.Type['vehicle_unlocked'])
                end

                if Config.AdvancedParking.enabled then
                    exports[Config.AdvancedParking.resourceName]:UpdateVehicle(data.vehicle)
                end
            elseif isKeyValid then
                if NetworkHasControlOfEntity(data.vehicle) then
                    lockVehicle(data.vehicle, lockedStatus)
                else
                    TriggerServerEvent("mx_carkeys:server:lockVehicle", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
                end

                TriggerServerEvent("mx_carkeys:server:vehicleEffects", NetworkGetNetworkIdFromEntity(data.vehicle), lockedStatus)
    
                if not IsPedInAnyVehicle(playerPed) then
                    lockAnimation()
                end

                vehicleAlarm(data.vehicle, false)
    
                if lockedStatus then
                    Notify.Send('Car Key', Translate('vehicle_locked'), 3000, Notify.Type['vehicle_locked'])
                else
                    Notify.Send('Car Key', Translate('vehicle_unlocked'), 3000, Notify.Type['vehicle_unlocked'])
                end

                if Config.AdvancedParking.enabled then
                    exports[Config.AdvancedParking.resourceName]:UpdateVehicle(data.vehicle)
                end
            else
                Notify.Send('Car Key', Translate('vehicle_incorrect_key'), 3000, Notify.Type['no_key_for_vehicle'])
            end
        else
            Notify.Send('Car Key', Translate('lock_Blacklisted'), 3000, Notify.Type['lock_Blacklisted'])
        end
    end
end
exports("lockVehicle", checkLockPossibility)

-- Functions
function toggleLock(slot)
    ESX.TriggerServerCallback('mx_carkeys:callback:getItemData', function(data)
        if data then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local vehicles = ESX.Game.GetVehiclesInArea(playerPos, 20)
    
            for k, vehicle in pairs(vehicles) do
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                local vehicleModel = GetDisplayNameFromVehicleModel(vehicleProps.model)
    
                if vehicleProps.plate == data.metadata.carKeysPlate then
                    checkLockPossibility(vehicle, GetVehicleDoorLockStatus(vehicle) ~= lockStatus.Locked)
    
                    break
                end
            end
        end
    end, slot)
end
exports('toggleLock', toggleLock)

-- open/close trunk
function toggleTrunk(slots)
    ESX.TriggerServerCallback('mx_carkeys:callback:getItemData', function(data)
        if data then
            -- local data = {}
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local vehicles = ESX.Game.GetVehiclesInArea(playerPos, 20)

            for k, vehicle in pairs(vehicles) do
                data.vehicle = vehicle
                data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle)
                local vehicleName = GetDisplayNameFromVehicleModel(vehicleProps.model)
                local vehicleModel = GetEntityModel(data.vehicle)

                print(json.encode(data, {indent = true}))
                print(data.vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1"):upper(), data.metadata.carKeysPlate:gsub("^%s*(.-)%s*$", "%1"):upper())

                if data.vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1"):upper() == data.metadata.carKeysPlate:gsub("^%s*(.-)%s*$", "%1"):upper() then
                    local isKeyValid, playerJob = lib.callback.await('mx_carkeys:callback:checkIsKeyValid', false, data) 

                    if IsJobVehicle(playerJob.name, data.vehicleProps.plate, vehicleModel) then
                        lockAnimation()

                        if trunkStatus[data.vehicle] then
                            trunkStatus[data.vehicle] = nil

                            SetVehicleDoorShut(data.vehicle, 5, false)
                        else
                            trunkStatus[data.vehicle] = true

                            SetVehicleDoorOpen(data.vehicle, 5, false, false)
                        end
                    elseif isKeyValid then
                        lockAnimation()

                        if trunkStatus[data.vehicle] then
                            trunkStatus[data.vehicle] = nil

                            SetVehicleDoorShut(data.vehicle, 5, false)
                        else
                            trunkStatus[data.vehicle] = true

                            SetVehicleDoorOpen(data.vehicle, 5, false, false)
                        end
                    end

                    break
                end
            end
        end
    end, slots)
end
exports('toggleTrunk', toggleTrunk)

-- check if the vehicle is in Config.WhitelistVehicles
function IsWhitelistVehicle(plate, model)
    for index, models in ipairs(Config.WhitelistVehicles.models) do
        if models == model then
            return true
        end
    end
    
    for index, plates in ipairs(Config.WhitelistVehicles.plates) do
        local plates = plates:upper()

        if plate:find(plates) then
            return true
        end
    end

    return false
end

-- check if the vehicle is in Config.JobVehicles 
function IsJobVehicle(playerJob, plate, model)
    local jobVehicles = Config.JobVehicles[playerJob]
    
    if jobVehicles == nil then
        return false
    end

    for index, models in ipairs(jobVehicles.models) do
        if models == model then
            return true
        end
    end
    
    for index, plates in ipairs(jobVehicles.plates) do
        local plates = plates:upper()

        if plate:find(plates) then
            return true
        end
    end

    return false
end

function vehicleAlarm(vehicle, boolean)
    SetVehicleAlarm(vehicle, boolean or true)

    if boolean == nil then
        SetVehicleAlarmTimeLeft(vehicle, Config.Lockpick.alarm.vehicleAlarmTime)
    end
end

function getChance()
    local percentNumber = math.random(0, 100)
    local decimalPercent = math.random(0, 99)
    local number = tonumber(percentNumber..'.'..decimalPercent)

    return number
end