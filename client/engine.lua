local vehicles = {}

-- Keybind for Starting/Stopping Engine
RegisterKeyMapping(Config.EngineCommand, 'Start/Stop your Engine', 'keyboard', Config.ToggleEngineKey)
RegisterCommand(Config.EngineCommand, function(source, args, Rawcommand)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

    if IsPedInAnyVehicle(playerPed, true) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        if Config.AdminKey.enabled then
            local isValidGroup, hasKey = lib.callback.await('mx_carkeys:callback:getAdminKey', false)
    
            if isValidGroup and hasKey then
                if vehicle ~= 0 and IsPedInAnyVehicle(playerPed, false) then
                    toggleEngine(vehicle)
                end
                return
            end
        end
    
        if IsWhitelistVehicle(vehicleProps.plate, vehicleModel) then
            if vehicle ~= 0 and IsPedInAnyVehicle(playerPed, false) then
                toggleEngine(vehicle)
                return
            end
        end
        
        if Config.ToggleEngineKeyOnly then
            if vehicle ~= 0 and IsPedInAnyVehicle(playerPed, false) then
                isToggleEngineValid(vehicle)
            end
        else
            if vehicle ~= 0 and IsPedInAnyVehicle(playerPed, false) then
                toggleEngine(vehicle)
            end
        end
    end

end)

function isToggleEngineValid(vehicle)
    local data = {}
    data.vehicle = vehicle
    data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(data.vehicleProps.model)
    local vehicleModel = GetEntityModel(data.vehicle)

    
    local isKeyValid, playerJob = lib.callback.await('mx_carkeys:callback:checkIsKeyValid', false, data) 

    if IsJobVehicle(playerJob.name, data.vehicleProps.plate, vehicleModel) then
        toggleEngine(data.vehicle)
    elseif isKeyValid then
        toggleEngine(data.vehicle)
    else
        Notify.Send('Car Key', Translate('need_key'), 3000, Notify.Type['no_key_for_vehicle_engine'])
    end
end
exports("isToggleEngineValid", isToggleEngineValid)

-- keep engine on/off
CreateThread(function()
	while true do
        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleTryingEnter = GetVehiclePedIsTryingToEnter(playerPed)

		Wait(0)

		if IsPedInAnyVehicle(playerPed, false) and not vehicles[currentVehicle] then
            local vehicle = currentVehicle
            local isEngineOn = GetIsVehicleEngineRunning(vehicle)

            vehicles[vehicle] = {isEngineOn}
		end

        for vehicle, data in pairs(vehicles) do 
            if DoesEntityExist(vehicle) then
                if (GetPedInVehicleSeat(vehicle, -1) == playerPed) or IsVehicleSeatFree(vehicle, -1) then
                    SetVehicleEngineOn(vehicle, vehicles[vehicle][1], true, false)
                    SetVehicleJetEngineOn(vehicle, vehicles[vehicle][1])

                    if not IsPedInAnyVehicle(playerPed, false) or (IsPedInAnyVehicle(playerPed, false) and vehicle ~= GetVehiclePedIsIn(playerPed, false)) then
                        if IsThisModelAHeli(GetEntityModel(vehicle)) or IsThisModelAPlane(GetEntityModel(vehicle)) then
                            if vehicles[vehicle][1] then
                                SetHeliBladesFullSpeed(vehicle)
                            end
                        end
                    end
			    else
                    vehicles[vehicle] = nil
                end
            end
        end
	end
end)

function GetEngineStatus(vehicle)
    local engine = false
    local playerPed = PlayerPedId()
    
    if vehicle then
        local isEngineOn = GetIsVehicleEngineRunning(vehicle)
        
        engine = isEngineOn
	elseif IsPedInAnyVehicle(playerPed, false) then 
        vehicle = GetVehiclePedIsIn(playerPed, false)
        
        engine = GetIsVehicleEngineRunning(vehicle)
    end 

    return engine
end
exports('GetEngineStatus', GetEngineStatus)

function SetEngineStatus(vehicle, status)
    local givenVehicle = vehicle
    local playerPed = PlayerPedId()
    
    if givenVehicle then
        local isEngineOn = status
        
        vehicles[givenVehicle] = {isEngineOn}
        
        vehicles[givenVehicle][1] = status
	elseif IsPedInAnyVehicle(playerPed, false) then 
        vehicle = GetVehiclePedIsIn(playerPed, false)
        
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            vehicles[vehicle][1] = status
		end 
    end 
end
RegisterNetEvent('mx_carkeys:client:setEngineStatus', SetEngineStatus)
exports('SetEngineStatus', SetEngineStatus)

-- start/stop engine
-- start/stop engine
function toggleEngine(givenVehicle)
    local vehicle = nil
    local playerPed = PlayerPedId()
    
    if givenVehicle then
        local vehicleHealth = GetVehicleEngineHealth(givenVehicle)
        local isEngineOn = GetIsVehicleEngineRunning(givenVehicle)
        
        if vehicleHealth > 10 then -- Überprüfen, ob der Fahrzeugzustand über 10% liegt
            vehicles[givenVehicle] = {isEngineOn}
            vehicles[givenVehicle][1] = not GetIsVehicleEngineRunning(givenVehicle)
        else
            vehicles[givenVehicle] = {false} -- Motor wird ausgeschaltet, wenn das Fahrzeug zu stark beschädigt ist
            SetVehicleEngineOn(givenVehicle, false, true, true) -- Motor erzwingen, auszuschalten
        end
    elseif IsPedInAnyVehicle(playerPed, false) then 
        vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if GetPedInVehicleSeat(vehicle, -1) then
            vehicles[vehicle][1] = not GetIsVehicleEngineRunning(vehicle)
            
            if vehicleHealth <= 10 then
                vehicles[vehicle] = {false} -- Motor wird ausgeschaltet, wenn das Fahrzeug zu stark beschädigt ist
                SetVehicleEngineOn(vehicle, false, true, true) -- Motor erzwingen, auszuschalten
            end 
        end 
    end

    if vehicles[givenVehicle or vehicle][1] then
        Notify.Send('Autoschlüssel', Translate('vehicle_engine_started'), 3000, Notify.Type['vehicle_engine_started'])
    else
        Notify.Send('Autoschlüssel', Translate('vehicle_engine_stopped'), 3000, Notify.Type['vehicle_engine_stopped'])
    end
end
RegisterNetEvent('mx_carkeys:client:toggleEngine', toggleEngine)
exports('toggleEngine', toggleEngine)

-- get vehicle data when toggling engine by key
function itemToggleEngine(slots)
    ESX.TriggerServerCallback('mx_carkeys:callback:getItemData', function(data)
        if data then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local vehicles = ESX.Game.GetVehiclesInArea(playerPos, 20)
    
            for k, vehicle in pairs(vehicles) do
                data.vehicle = vehicle
                data.vehicleProps = ESX.Game.GetVehicleProperties(data.vehicle)
                local vehicleName = GetDisplayNameFromVehicleModel(data.vehicleProps.model)
                local vehicleModel = GetEntityModel(data.vehicle)
    
                if data.vehicleProps.plate == data.metadata.carKeysPlate then
                    local isKeyValid, playerJob = lib.callback.await('mx_carkeys:callback:checkIsKeyValid', false, data) 
    
                    if IsJobVehicle(playerJob.name, data.vehicleProps.plate, vehicleModel) then
                        lockAnimation()
    
                        toggleEngine(data.vehicle)
                    elseif isKeyValid then
                        lockAnimation()
    
                        toggleEngine(data.vehicle)
                    end
    
                    break
                end
            end
        end
    end, slots)
end
exports('itemToggleEngine', itemToggleEngine)