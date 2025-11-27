Config.Vehiclenames = {
    -- ['<gameName>'] = 'Vehicle Name Label',
    
    ['GAMENAME'] = 'VEHICLE NAME',
}

CreateThread(function()
    for gameName, label in pairs(Config.Vehiclenames) do
        AddTextEntry(gameName, label)
    end
end)