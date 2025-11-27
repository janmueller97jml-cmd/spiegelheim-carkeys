local Inventory = Config.Inventory
local loaded_ox, loaded_qs = Inventory.ox_inventory and not Inventory.qs_inventory, Inventory.qs_inventory and not Inventory.ox_inventory

if loaded_ox then
    ox_inventory = exports.ox_inventory
elseif loaded_qs then
end

-- Set Metadata Visible
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
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
    elseif loaded_qs then
    end
end)

RegisterNetEvent('onResourceStart', function(resourceName)
    if loaded_ox then
        if resourceName == 'ox_inventory' then
            Wait(5000)
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
    elseif loaded_qs then
    end
end)

-- Key Mapping and Commands
RegisterKeyMapping(Config.LockCommand, 'Lock/Unlock your Vehicle', 'keyboard', Config.CarLockKey)
RegisterCommand(Config.LockCommand, function(source, args, Rawcommand)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerPos)

    checkLockPossibility(vehicle, GetVehicleDoorLockStatus(vehicle) ~= lockStatus.Locked)
end)

-- Sync Events
RegisterNetEvent('mx_carkeys:client:vehicleEffects', function(vehicleID, lockedStatus)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleID)
    
    if DoesEntityExist(vehicle) then
        vehicleEffects(vehicle, lockedStatus)
    end
end)

RegisterNetEvent('mx_carkeys:client:lockVehicle', function(vehicleID, lockedStatus, lockpick)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleID)
    
    if DoesEntityExist(vehicle) then
        lockVehicle(vehicle, lockedStatus, lockpick)
    end
end)