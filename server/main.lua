local Inventory = Config.Inventory
local loaded_ox, loaded_qs = Inventory.ox_inventory, Inventory.qs_inventory

if Config.DebugLevel then
    if loaded_ox then
        if Config.DebugLevel == 1 or Config.DebugLevel == 3 then
            print(tostring(loaded_ox)..' OX Inventory is loaded')
        end
    elseif loaded_qs then
        if Config.DebugLevel == 1 or Config.DebugLevel == 3 then
            print(tostring(loaded_qs)..' QS Inventory is loaded')
        end
    end
end

if loaded_ox then
    ox_inventory = exports.ox_inventory
elseif loaded_qs and Config.QSInventoryV2 then
    qs_inventory = exports['qs-inventory']
end

local temporaryKeys = {}

-- filling empty lockID's
CreateThread(function()
    local count = 0

    MySQL.Async.fetchAll('SELECT * FROM '..Config.DefaultDatabase, function(result)
        for k, v in pairs(result) do
            if not v.lockID then
                Wait(10)
                
                local lockID = ESX.GetRandomString(16)

                count = count + 1

                MySQL.update('UPDATE '..Config.DefaultDatabase..' SET lockID = ? WHERE plate = ?', {lockID, v.plate})
            end
        end

        if count > 0 then
            if Config.DebugLevel == 1 or Config.DebugLevel == 3 then
                print('[^3WARNING^0] '..count..' ^4empty lockID columns got newly generated lockID\'s in ^0\"'..Config.DefaultDatabase..'\"')
            end
        end
    end)

    for database, value in pairs(Config.Databases) do
        MySQL.Async.fetchAll('SELECT * FROM '..database, function(result)
            for k, v in pairs(result) do
                print(json.encode(v.lockID))
                if not v.lockID then
                    Wait(10)
                    
                    local lockID = ESX.GetRandomString(16)
                    
                    count = count + 1
    
                    MySQL.update('UPDATE '..database..' SET lockID = ? WHERE plate = ?', {lockID, v.plate})
                end
            end
    
            if count > 0 then
                if Config.DebugLevel == 1 or Config.DebugLevel == 3 then
                    print('[^3WARNING^0] '..count..' ^4empty lockID columns got newly generated lockID\'s in ^0\"'..database..'\"')
                end
            end
        end)
    end
end)

-- Sync Events
RegisterNetEvent('mx_carkeys:server:lockVehicle', function(vehicleID, lockedStatus)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleID)

    if DoesEntityExist(vehicle) then
        local entityOwner = NetworkGetEntityOwner(vehicle)

        TriggerClientEvent('mx_carkeys:client:lockVehicle', entityOwner, vehicleID, lockedStatus)
    end
end)

RegisterNetEvent('mx_carkeys:server:vehicleEffects', function(vehicleID, lockedStatus)
    TriggerClientEvent('mx_carkeys:client:vehicleEffects', -1, vehicleID, lockedStatus)
end)

RegisterNetEvent('mx_carkeys:server:alert', function(playerPos, vehiclePos)
    Config.Lockpick.serverAlert(source, playerPos, vehiclePos)
end)

RegisterNetEvent('mx_carkeys:server:removeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem(item, 1)
end)

-- Callbacks
lib.callback.register('mx_carkeys:callback:getAdminKey', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local xPlayerGroup = xPlayer.getGroup()
    
    if loaded_ox then
        return table.contains(Config.AdminKey.groups, xPlayerGroup), ox_inventory:GetItemCount(src, Config.AdminKey.item) >= 1
    elseif loaded_qs then
        if Config.QSInventoryV2 then
            return table.contains(Config.AdminKey.groups, xPlayerGroup), exports['qs-inventory']:GetItemTotalAmount(src, Config.AdminKey.item) >= 1
        end
    end
end)

lib.callback.register('mx_carkeys:callback:removeVehicleKey', function(src, data)
    local xPlayer = ESX.GetPlayerFromId(src)

    if loaded_ox then
        playerItems = ox_inventory:GetInventoryItems(src)
    
        for k, v in pairs(playerItems) do
            if v.metadata.carKeysLockID ~= nil then
                if v.metadata.carKeysPlate == data.vehicleProps.plate then
                    local MySQL_Query = 'SELECT lockID FROM '..Config.DefaultDatabase..' WHERE plate = ?'
    
                    if v.metadata.carKeysDatabase then
                        MySQL_Query = 'SELECT lockID FROM '..v.metadata.carKeysDatabase..' WHERE plate = ?'
                    end
    
                    MySQL.Async.fetchAll(MySQL_Query, {data.vehicleProps.plate}, function(result)
                        result = result[1]
                
                        local keyIsValid = false
                
                        if result then
                            if result.lockID == v.metadata.carKeysLockID then
                                success = exports.ox_inventory:RemoveItem(src, 'carkey', v.count, v.metadata)
                            end
                        elseif temporaryKeys[data.vehicleProps.plate] then
                            if temporaryKeys[data.vehicleProps.plate].lockID == v.metadata.carKeysLockID then
                                success = exports.ox_inventory:RemoveItem(src, 'carkey', v.count, v.metadata)
                            end
                        end
                    end)
                end
            end
        end
    elseif loaded_qs and not Config.QSInventoryV2 then
        print('this Quasar Inventory Version is not Supported in this function')
    elseif loaded_qs and Config.QSInventoryV2 then
        playerItems = xPlayer.getInventory()

        for k, v in pairs(playerItems) do
            if v.info.LockID ~= nil then
                if v.info.carKeysPlate == data.vehicleProps.plate then
                    local MySQL_Query = 'SELECT lockID FROM '..Config.DefaultDatabase..' WHERE plate = ?'

                    if v.metadata.carKeysDatabase then
                        MySQL_Query = 'SELECT lockID FROM '..v.info.Database..' WHERE plate = ?'
                    end

                    MySQL.Async.fetchAll(MySQL_Query, {data.vehicleProps.plate}, function(result)
                        result = result[1]
                
                        local keyIsValid = false
                
                        if result then
                            if result.lockID == v.info.LockID then
                                exports['qs-inventory']:RemoveItem(src, 'carkey', v.count, nil, v.metadata)

                                success = true
                            end
                        elseif temporaryKeys[data.vehicleProps.plate] then
                            if temporaryKeys[data.vehicleProps.plate].lockID == v.info.LockID then
                                exports['qs-inventory']:RemoveItem(src, 'carkey', v.count, nil, v.metadata)

                                success = true
                            end
                        end
                    end)
                end
            end
        end
    end

    return success
end)

lib.callback.register('mx_carkeys:callback:checkIsKeyValid', function(src, data)
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerJob = xPlayer.getJob()
    local keyIsValid = false 
    local trimmedPlate = data.vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1"):upper()
    
    if loaded_ox then
        playerItems = ox_inventory:GetInventoryItems(src)

        for k, v in pairs(playerItems) do
            if v.metadata.carKeysLockID ~= nil then
                -- if v.metadata.carKeysPlate == trimmedPlate then
                    local MySQL_Query = 'SELECT lockID FROM '..Config.DefaultDatabase..' WHERE plate = ?'

                    if v.metadata.carKeysDatabase then
                        MySQL_Query = 'SELECT lockID FROM '..v.metadata.carKeysDatabase..' WHERE plate = ?'
                    end

                    local result = MySQL.query.await(MySQL_Query, {trimmedPlate})[1]

                    if result then
                        if result.lockID == v.metadata.carKeysLockID then
                            keyIsValid = true
                        end
                    elseif temporaryKeys[trimmedPlate] then
                        if temporaryKeys[trimmedPlate].lockID == v.metadata.carKeysLockID then
                            keyIsValid = true
                        end
                    end
                -- end
            end
        end
    elseif loaded_qs then
        playerItems = xPlayer.getInventory()

        for k, v in pairs(playerItems) do
            if v.info.LockID ~= nil then
                -- if v.info.carKeysPlate == trimmedPlate then
                    local MySQL_Query = 'SELECT lockID FROM '..Config.DefaultDatabase..' WHERE plate = ?'

                    if v.info.carKeysDatabase then
                        MySQL_Query = 'SELECT lockID FROM '..v.info.Database..' WHERE plate = ?'
                    end

                    local result = MySQL.query.await(MySQL_Query, {trimmedPlate})[1]
                    
                    if result then
                        if result.lockID == v.info.LockID then
                            keyIsValid = true
                        end
                    elseif temporaryKeys[trimmedPlate] then
                        if temporaryKeys[trimmedPlate].lockID == v.info.LockID then
                            keyIsValid = true
                        end
                    end
                -- end
            end
        end
    end
        
    return keyIsValid or false, playerJob
end)

-- Check if a vehicle is job-owned (owner column matches player's job name)
lib.callback.register('mx_carkeys:callback:isJobOwnedVehicle', function(src, data)
    if not Config.JobOwnerIsKeyless then
        return false
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    local playerJob = xPlayer.getJob()
    local trimmedPlate = data.vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1"):upper()
    local ownerColumn = Config.JobOwnerColumnName or 'owner'

    -- Check in default database
    local MySQL_Query = 'SELECT ' .. ownerColumn .. ' FROM ' .. Config.DefaultDatabase .. ' WHERE plate = ?'
    local result = MySQL.query.await(MySQL_Query, {trimmedPlate})

    if result and result[1] then
        local vehicleOwner = result[1][ownerColumn]
        if vehicleOwner and vehicleOwner == playerJob.name then
            return true
        end
    end

    -- Check in additional databases
    for database, value in pairs(Config.Databases) do
        local dbOwnerColumn = value.ownerColumn or ownerColumn
        local MySQL_Query = 'SELECT ' .. dbOwnerColumn .. ' FROM ' .. database .. ' WHERE plate = ?'
        local result = MySQL.query.await(MySQL_Query, {trimmedPlate})

        if result and result[1] then
            local vehicleOwner = result[1][dbOwnerColumn]
            if vehicleOwner and vehicleOwner == playerJob.name then
                return true
            end
        end
    end

    return false
end)

ESX.RegisterServerCallback('mx_carkeys:callback:getVehicles', function(src, cb)
    local vehicles = {}
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        for database, value in pairs(Config.Databases) do
            local MySQL_Query = 'SELECT plate, '..value.vehiclePropsColumn..', lockID FROM '..database..' WHERE '..value.ownerColumn..' = ?'

            if value.modelSeperateColumn ~= false then
                MySQL_Query = 'SELECT '..value.modelSeperateColumn..', plate, '..value.vehiclePropsColumn..', lockID FROM '..database..' WHERE '..value.ownerColumn..' = ?'
            end

            local results = MySQL.Sync.fetchAll(MySQL_Query, {xPlayer.identifier})

            for k, v in pairs(results) do
                if value.modelSeperateColumn ~= false then
                    local vehicleProps = {}
                    
                    vehicleProps = json.decode(v[value.vehiclePropsColumn])
                    vehicleProps.model = v[value.modelSeperateColumn]
                    
                    table.insert(vehicles, {v.plate, v[value.modelSeperateColumn], v.lockID, vehicleProps, database})
                else
                    table.insert(vehicles, {v.plate, json.decode(v[value.vehiclePropsColumn]).model, v.lockID, json.decode(v[value.vehiclePropsColumn]), database})
                end
            end
        end

        local results = MySQL.Sync.fetchAll('SELECT plate, vehicle, lockID FROM owned_vehicles WHERE owner = ?', {xPlayer.identifier})
        
        for k, v in pairs(results) do
            table.insert(vehicles, {v.plate, json.decode(v.vehicle).model, v.lockID, json.decode(v.vehicle), 'owned_vehicles'})
        end

        cb(vehicles)
    else
        if Config.DebugLevel == 1 or Config.DebugLevel == 3 then
            print("^1[ERROR] \"playerData\" was nil while getting owned vehicles for id " .. tostring(playerId))
        end
    end
end)

ESX.RegisterServerCallback('mx_carkeys:callback:buyVehicle', function(src, cb, data)
    local status, response = false, nil
    local lockID = ESX.GetRandomString(16)
    local vehiclePlate = data.plate or data.vehicleProps.plate
    local trimmedPlate = vehiclePlate:gsub("^%s*(.-)%s*$", "%1"):upper()

    local database = data.database or Config.Databases.defaultDatabase

    local MySQL_Query = 'UPDATE '..database..' SET lockID = ? WHERE plate = ?'

    Wait(1000)

    MySQL.update(MySQL_Query, {lockID, trimmedPlate})

    if loaded_ox then
        if Config.RenameItem then 
            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                label = trimmedPlate,
                carKeysPlate = trimmedPlate,
                carKeysModel = data.vehicleModel,
                carKeysLockID = lockID,
                carKeysDatabase = database
            })
        else
            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                carKeysPlate = trimmedPlate,
                carKeysModel = data.vehicleModel,
                carKeysLockID = lockID,
                carKeysDatabase = database
            })
        end
    elseif loaded_qs and not Config.QSInventoryV2 then
        TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, data.count or 1, false, {
            Plate = trimmedPlate, 
            Model = data.vehicleModel, 
            LockID = lockID,
            Database = database,
            showAllDescriptions = true
        })

        status = true
    elseif loaded_qs and Config.QSInventoryV2 then
        qs_inventory:AddItem(src, Config.KeyItem, data.count or 1, nil, {
            Plate = trimmedPlate, 
            Model = data.vehicleModel, 
            LockID = lockID,
            Database = database,
            showAllDescriptions = true
        })

        status = true
    end

    cb(status)
end)

ESX.RegisterServerCallback('mx_carkeys:callback:giveCarKey', function(src, cb, data)
    local xPlayer = ESX.GetPlayerFromId(src)
    local status, response = false, nil
    local vehiclePlate = data.plate or data.vehicleProps.plate
    local trimmedPlate = vehiclePlate:gsub("^%s*(.-)%s*$", "%1"):upper()

    if data.blankKey then
        local item = xPlayer.hasItem(Config.BlankKeyItem)

        if not item then
            cb('no_blank_key')
            
            return
        end
        
        if item.count == 0 then
            cb('no_blank_key')
            
            return
        end

        if item.count < data.count then
            data.count = item.count
        end
        
        xPlayer.removeInventoryItem(Config.BlankKeyItem, count)
    end


    local results = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE plate = ?', {trimmedPlate})

    if #results == 0 then
        for database, value in pairs(Config.Databases) do
            local results = MySQL.query.await('SELECT plate FROM '..database..' WHERE plate = ?', {trimmedPlate})

            if #results >= 1 then
                MySQL.Async.fetchAll('SELECT lockID FROM '..database..' WHERE plate = ?', {data.plate or data.vehicleProps.plate}, function(result)
                    result = result[1]
                    local status, response = false, nil
                    local xPlayer = ESX.GetPlayerFromId(src)
            
                    if loaded_ox then
                        if Config.RenameItem then 
                            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                                label = data.plate,
                                carKeysPlate = data.plate, 
                                carKeysModel = data.vehicleModel, 
                                carKeysLockID = result.lockID,
                                carKeysDatabase = database
                            })
                        else
                            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                                carKeysPlate = data.plate, 
                                carKeysModel = data.vehicleModel, 
                                carKeysLockID = result.lockID,
                                carKeysDatabase = database
                            })
                        end
                    elseif loaded_qs and not Config.QSInventoryV2 then
                        TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, data.count or 1, false, {
                            Plate = data.plate, 
                            Model = data.vehicleModel, 
                            LockID = result.lockID,
                            Database = database,
                            showAllDescriptions = true
                        })
            
                        status = true
                    elseif loaded_qs and Config.QSInventoryV2 then
                        qs_inventory:AddItem(src, Config.KeyItem, data.count or 1, nil, {
                            Plate = data.plate, 
                            Model = data.vehicleModel, 
                            LockID = result.lockID,
                            Database = database,
                            showAllDescriptions = true
                        })
                
                        status = true
                    end
                
                    cb(status)
                end)

                break
            end
        end
    else
        MySQL.Async.fetchAll('SELECT lockID FROM owned_vehicles WHERE plate = ?', {data.plate or data.vehicleProps.plate}, function(result)
            result = result[1]
            local status, response = false, nil
            local xPlayer = ESX.GetPlayerFromId(src)
    
            if loaded_ox then
                if Config.RenameItem then 
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                        label = data.plate,
                        carKeysPlate = data.plate, 
                        carKeysModel = data.vehicleModel, 
                        carKeysLockID = result.lockID
                    })
                else
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                        carKeysPlate = data.plate, 
                        carKeysModel = data.vehicleModel, 
                        carKeysLockID = result.lockID
                    })
                end
            elseif loaded_qs and not Config.QSInventoryV2 then
                TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, data.count or 1, false, {
                    Plate = data.plate, 
                    Model = data.vehicleModel, 
                    LockID = result.lockID,
                    showAllDescriptions = true
                })
    
                status = true
            elseif loaded_qs and Config.QSInventoryV2 then
                qs_inventory:AddItem(src, Config.KeyItem, data.count or 1, nil, {
                    Plate = data.plate, 
                    Model = data.vehicleModel, 
                    LockID = result.lockID,
                    showAllDescriptions = true
                })
        
                status = true
            end
        
            cb(status)
        end)
    end
end)

ESX.RegisterServerCallback('mx_carkeys:callback:createTempKey', function(src, cb, data)
    local status = false
    local xPlayer = ESX.GetPlayerFromId(src)
    local lockID = ESX.GetRandomString(16)

    temporaryKeys[data.vehicleProps.plate] = {
        vehicle = data.vehicle,
        plate = data.vehicleProps.plate,
        lockID = lockID
    }

    if loaded_ox then
        if Config.RenameItem then 
            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                label = data.plate or data.vehicleProps.plate,
                carKeysPlate = data.plate or data.vehicleProps.plate, 
                carKeysModel = data.vehicleModel, 
                carKeysLockID = lockID
            })
        else
            status, response = ox_inventory:AddItem(src, Config.KeyItem, data.count or 1, {
                carKeysPlate = data.plate or data.vehicleProps.plate, 
                carKeysModel = data.vehicleModel, 
                carKeysLockID = lockID
            })
        end
    elseif loaded_qs and not Config.QSInventoryV2 then
        TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, data.count or 1, false, {
            Plate = data.plate or data.vehicleProps.plate, 
            Model = data.vehicleModel, 
            LockID = lockID,
            showAllDescriptions = true
        })

        status = true
    elseif loaded_qs and Config.QSInventoryV2 then
        qs_inventory:AddItem(src, Config.KeyItem, data.count or 1, nil, {
            Plate = data.plate or data.vehicleProps.plate, 
            Model = data.vehicleModel, 
            LockID = lockID,
            showAllDescriptions = true
        })

        status = true
    end

    cb(status)
end)

ESX.RegisterServerCallback('mx_carkeys:callback:giveKey', function(src, cb, plate, vehicleModel, database)
    MySQL.Async.fetchAll('SELECT lockID FROM '..database..' WHERE plate = ?', {plate}, function(result)
        result = result[1]
        local status, response = false, nil
        local xPlayer = ESX.GetPlayerFromId(src)

        if xPlayer.getAccount(Config.LocksmithShops.payType).money >= Config.LocksmithShops.buyKeyPrice then
            xPlayer.removeAccountMoney(Config.LocksmithShops.payType, Config.LocksmithShops.buyKeyPrice)

            if loaded_ox then
                if Config.RenameItem then 
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                        label = plate,
                        carKeysPlate = plate, 
                        carKeysModel = vehicleModel, 
                        carKeysLockID = result.lockID,
                        carKeysDatabase = database
                    })
                else
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, 1, {
                        carKeysPlate = plate, 
                        carKeysModel = vehicleModel, 
                        carKeysLockID = result.lockID,
                        carKeysDatabase = database
                    })
                end
            elseif loaded_qs and not Config.QSInventoryV2 then
                TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, 1, false, {
                    Plate = plate, 
                    Model = vehicleModel, 
                    LockID = result.lockID,
                    Database = database,
                    showAllDescriptions = true
                })

                status = true
            elseif loaded_qs and Config.QSInventoryV2 then
                qs_inventory:AddItem(src, Config.KeyItem, 1, nil, {
                    Plate = plate, 
                    Model = vehicleModel, 
                    LockID = result.lockID,
                    Database = database,
                    showAllDescriptions = true
                })
        
                status = true
            end
        
            cb(status)
        else
            cb(status)
        end
    end)
end)

ESX.RegisterServerCallback('mx_carkeys:callback:changeLockID', function(src, cb, plate, vehicleModel, database)
    local status, response = false, nil
    local xPlayer = ESX.GetPlayerFromId(src)
    local lockID = ESX.GetRandomString(16)
    local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1"):upper()

    if xPlayer.getAccount(Config.LocksmithShops.payType).money >= Config.LocksmithShops.changeLockPrice then
        xPlayer.removeAccountMoney(Config.LocksmithShops.payType, Config.LocksmithShops.changeLockPrice)
        
        MySQL.update('UPDATE '..database..' SET lockID = ? WHERE plate = ?', {lockID, trimmedPlate})
    
        if Config.LocksmithShops.giveNewLockKey then
            if loaded_ox then
                if Config.RenameItem then 
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                        label = trimmedPlate,
                        carKeysPlate = trimmedPlate, 
                        carKeysModel = vehicleModel, 
                        carKeysLockID = lockID,
                        carKeysDatabase = database
                    })
                else
                    status, response = ox_inventory:AddItem(src, Config.KeyItem, 1, {
                        carKeysPlate = trimmedPlate, 
                        carKeysModel = vehicleModel, 
                        carKeysLockID = lockID,
                        carKeysDatabase = database
                    })
                end
            elseif loaded_qs and not Config.QSInventoryV2 then
                TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, 1, false, {
                    Plate = trimmedPlate, 
                    Model = vehicleModel, 
                    LockID = lockID,
                    Database = database,
                    showAllDescriptions = true
                })

                status = true
            elseif loaded_qs and Config.QSInventoryV2 then
                qs_inventory:AddItem(src, Config.KeyItem, 1, nil, {
                    Plate = trimmedPlate, 
                    Model = vehicleModel, 
                    LockID = lockID,
                    Database = database,
                    showAllDescriptions = true
                })
        
                status = true
            end
        else
            status = true
        end

        cb(status)
    else
        cb(status)
    end
end)

ESX.RegisterServerCallback('mx_carkeys:callback:changeLock', function(src, cb, plate, vehicleModel, count, blankKey)
    local status, response = false, nil
    local xPlayer = ESX.GetPlayerFromId(src)
    local lockID = ESX.GetRandomString(16)
    local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1"):upper()

    if blankKey then
        local item = xPlayer.hasItem(Config.BlankKeyItem)
        
        if not item then
            cb('no_blank_key')
            return
        end
        
        if item.count == 0 then
            cb('no_blank_key')
            return
        end
        
        if item.count < count then
            count = item.count
        end
        
        xPlayer.removeInventoryItem(Config.BlankKeyItem, count)
    end

    local results = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE plate = ?', {trimmedPlate})

    if #results == 0 then
        for database, value in pairs(Config.Databases) do
            local results = MySQL.query.await('SELECT plate FROM '..database..' WHERE plate = ?', {trimmedPlate})

            if #results >= 1 then
                MySQL.update('UPDATE '..database..' SET lockID = ? WHERE plate = ?', {lockID, trimmedPlate})

                if loaded_ox then
                    if Config.RenameItem then 
                        status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                            label = trimmedPlate,
                            carKeysPlate = trimmedPlate, 
                            carKeysModel = vehicleModel, 
                            carKeysDatabase = database,
                            carKeysLockID = lockID
                        })
                    else
                        status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                            carKeysPlate = trimmedPlate, 
                            carKeysModel = vehicleModel, 
                            carKeysDatabase = database,
                            carKeysLockID = lockID
                        })
                    end
                elseif loaded_qs and not Config.QSInventoryV2 then
                    TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, count or 1, false, {
                        Plate = trimmedPlate, 
                        Model = vehicleModel, 
                        LockID = lockID,
                        Database = database,
                        showAllDescriptions = true
                    })
            
                    status = true
                elseif loaded_qs and Config.QSInventoryV2 then
                    qs_inventory:AddItem(src, Config.KeyItem, count or 1, nil, {
                        Plate = trimmedPlate, 
                        Model = vehicleModel, 
                        LockID = lockID,
                        Database = database,
                        showAllDescriptions = true
                    })
            
                    status = true
                end

                break
            end
        end
    else
        MySQL.update('UPDATE owned_vehicles SET lockID = ? WHERE plate = ?', {lockID, trimmedPlate})
        

        if loaded_ox then
            if Config.RenameItem then 
                status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                    label = trimmedPlate,
                    carKeysPlate = trimmedPlate, 
                    carKeysModel = vehicleModel, 
                    carKeysLockID = lockID
                })
            else
                status, response = ox_inventory:AddItem(src, Config.KeyItem, count or 1, {
                    carKeysPlate = trimmedPlate, 
                    carKeysModel = vehicleModel, 
                    carKeysLockID = lockID
                })
            end
        elseif loaded_qs and not Config.QSInventoryV2 then
            TriggerEvent('qs-inventory:addItem', src, Config.KeyItem, count or 1, false, {
                Plate = trimmedPlate, 
                Model = vehicleModel, 
                LockID = lockID,
                showAllDescriptions = true
            })

            status = true
        elseif loaded_qs and Config.QSInventoryV2 then
            qs_inventory:AddItem(src, Config.KeyItem, count or 1, nil, {
                Plate = trimmedPlate, 
                Model = vehicleModel, 
                LockID = lockID,
                showAllDescriptions = true
            })

            status = true
        end
    end

    cb(status)
end)

ESX.RegisterServerCallback('mx_carkeys:callback:getItemData', function(src, cb, slot)
    if loaded_ox then
        local itemData = ox_inventory:GetSlot(src, slot)
    
        cb(itemData)
    else
        cb(nil)
    end
end)

-- Useable Item
if Config.Lockpick.enabled then
    ESX.RegisterUsableItem(Config.Lockpick.item, function(src)
       local xPlayer = ESX.GetPlayerFromId(src)

       xPlayer.triggerEvent('mx_carkeys:client:startLockpick')
    end)
end

if Config.Hotwire.enabled then
    ESX.RegisterUsableItem(Config.Hotwire.item, function(src)
       local xPlayer = ESX.GetPlayerFromId(src)

       xPlayer.triggerEvent('mx_carkeys:client:startHotwire')
    end)
end