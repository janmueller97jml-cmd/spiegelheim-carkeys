Config = {}

-- debugs are not the completely available, will add them over time to make debugging and Support easier
Config.DebugLevel = 3 -- for debugging available levels turned off = "0", server only = "1", client only = "2", both "3"

Config.Locale = 'en' -- set this to your language

Config.Inventory = { -- sets the inventory you are using
    ox_inventory = GetResourceState('ox_inventory') == 'started', -- if this won't work use this instead // ox_inventory = true,
    qs_inventory = GetResourceState('qs-inventory') == 'started' -- if this won't work use this instead // qs_inventory = true,
}

Config.QSInventoryV2 = false

-- if you use the resource AdvancedParking by Kiminaze, this updates the Vehicle everytime you lock or unlock it
Config.AdvancedParking = {
    enabled = false,
    resourceName = 'AdvancedParking',
}

Config.AdminKey = { -- when this key is in an inventory of a player then he can start every vehicle
    enabled = true,
    item = 'admin_carkey', -- the Item which you want to be an admin key, does not use Metadata
    groups = { -- which group can use the key
        'superadmin', 'admin', 'mod'
    },
    vehicles = { -- which vehicles he can lock with that key, for example for some admin car you have
        `adder`
    }
}

Config.Menu = "oxContextMenu" -- which ESX Menu you want to use. Accepted Values: "ESXDefaultMenu", "oxContextMenu"
Config.ESXMenuAlign = "left"

Config.KeyItem = 'carkey' -- the item name
Config.BlankKeyItem = 'blank_carkey' -- if mechanics create a key and the export says that a blank key is needed then it uses this item
Config.LockCommand = 'vehicleLock' -- without this Config.CarLockKey will not work
Config.CarLockKey = 'U' -- the keybind // https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.LockDistance = 20 -- distance in which you can lock your car
Config.PlayLockSound = false

Config.EngineCommand = 'toggleEngine' -- without this Config.CarLockKey will not work
Config.ToggleEngineKey = 'M' -- the keybind // https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.ToggleEngineKeyOnly = true -- if this is true you'll need the key to turn the engine on/off

Config.RenameItem = true -- renames the carkey Item to the License Plate of the vehicle
Config.Metadata = { -- you can choose which metadata you want to see in your key description
    hidePlate = false,
    hideModel = false,
    hideLockID = true
}

Config.DefaultDatabase = 'owned_vehicles'
Config.Databases = {

    -- add your owned vehicles databases here when you want to use multiple
    -- if you use jobscreator you can use this, else this is just an example how it works
    -- ['jobs_garages'] = {
    --     ownerColumn = 'identifier', -- the column where the identifier is at 
    --     vehiclePropsColumn = 'vehicle_props', -- the column where the vehicleProps are at
    --     modelSeperateColumn = 'vehicle', -- if false it is getting the model from the vehicle props, else enter the column where the model is at example: "model"
    -- }
} 

Config.Lockpick = {
    enabled = true, -- enable / disable lockpicking 
    item = 'lockpick', -- the item for lockpicking
    time = 5000, -- time to lockpick a car
    removeOnSuccess = true, -- removes item when the vehicle got opened
    removeOnFail = true, -- removes item when the vehicle lockpicking failed
    unlockChance = 75.0, -- chance to unlock the car in percent. set to 100 to always unlock
    dispatch = {
        enabled = true, -- enable / disable dispatches to the police
        alertChance = 75.0, -- chance to alert the police in percent. set to 100 to always alert the police
        alertedJobs = {'police', 'sheriff'}, -- jobs to receive a dispatch
    },
    alarm = {
        alarmWhenLockpicking = false, -- start the alarm as soon as the lockpicking started
        vehicleAlarmTime = 60000, -- time in miliseconds
        waitAlarmStart = 0, -- wait in miliseconds // wait before the alarm turns on
    },
    animation = {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', -- animation dictionary
        anim = 'machinic_loop_mechandplayer' -- animation
    }, 
    clientAlert = function(playerPos, vehiclePos) -- does only work if dispatches are enabled
        print(string.format('alerted client side \nPlayer Coords: %s \nVehicle Coords: %s', playerPos, vehiclePos))
    end,
    serverAlert = function(source, playerPos, vehiclePos) -- does only work if dispatches are enabled
        print(string.format('alerted server side \nSource: %s \nPlayer Coords: %s \nVehicle Coords: %s', source, playerPos, vehiclePos))
    end,
    blacklist = { -- Blacklist for Vehicle Classes or and Models. Set each to true for blacklisting 
        vehicleClasses = {
            [0] = false, -- Compacts
            [1] = false, -- Sedans
            [2] = false, -- SUVs
            [3] = false, -- Coupes
            [4] = false, -- Muscle
            [5] = false, -- Sports Classics
            [6] = false, -- Sports
            [7] = false, -- Super
            [8] = false, -- Motorcycles
            [9] = false, -- Off-road
            [10] = false, -- Industrial
            [11] = false, -- Utility
            [12] = false, -- Vans
            [13] = false, -- Cycles
            [14] = false, -- Boats
            [15] = false, -- Helicopters
            [16] = false, -- Planes
            [17] = false, -- Service
            [18] = false, -- Emergency
            [19] = false, -- Military
            [20] = false, -- Commercial
            [21] = false, -- Trains
            [21] = false, -- Open Wheels
        },
        vehicleModels = {
            [`adder`] = false,
        }
    }
}

Config.Hotwire = {
    enabled = true, -- enable / disable hotwiring
    item = 'plier', -- the item for hotwiring
    time = 5000,  -- time it takes to hotwire
    removeOnSuccess = false, -- removes item when the vehicle got started
    removeOnFail = false, -- removes item when the vehicle hotwiring failed
    startChance = 75.0, -- chance to start the engine in percent. set to 100 to always start the engine
    animation = {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', -- animation dictionary
        anim = 'machinic_loop_mechandplayer' -- animation
    },
    blacklist = { -- Blacklist for Vehicle Classes or and Models. Set each to true for blacklisting 
        vehicleClasses = {
            [0] = false, -- Compacts
            [1] = false, -- Sedans
            [2] = false, -- SUVs
            [3] = false, -- Coupes
            [4] = false, -- Muscle
            [5] = false, -- Sports Classics
            [6] = false, -- Sports
            [7] = false, -- Super
            [8] = false, -- Motorcycles
            [9] = false, -- Off-road
            [10] = false, -- Industrial
            [11] = false, -- Utility
            [12] = false, -- Vans
            [13] = false, -- Cycles
            [14] = false, -- Boats
            [15] = false, -- Helicopters
            [16] = false, -- Planes
            [17] = false, -- Service
            [18] = false, -- Emergency
            [19] = false, -- Military
            [20] = false, -- Commercial
            [21] = false, -- Trains
            [21] = false, -- Open Wheels
        },
        vehicleModels = {
            [`adder`] = false,
        }
    }
}

Config.useOxTarget = false -- if you want to use ox Target for the locksmith shop access
Config.LocksmithShops = {
    giveNewLockKey = true, -- when true it gives the person a new key when changing the LockID
    payType = 'money', -- do you want to pay with a bank card, cash or even black_money | 'bank', 'money', 'black_money'
    changeLockPrice = 1000, -- the price for changing the car locks
    buyKeyPrice = 100 -- the price for buying a new key
}

Config.LockSmith = {
	{
		pedModel = `s_m_m_autoshop_01`, -- ped model 
		coords = vector3(170.33, -1799.13, 28.32), -- coords where the locksmith is located
        heading = 310.0, -- heading where the locksmith is looking at
        blipSettings = { -- some blip settings // https://docs.fivem.net/docs/game-references/blips/
            blipSprite = 134, -- the blip icon
            blipColor = 28, -- the blip color shown
            blipScale = 0.8, -- the size of the blip on the map
        }
	},
}

-- Lock Blacklist for Vehicle Classes or and Models. Usefull for Bikes that cant be locked 
Config.LockBlacklist = {
    vehicleClasses = {
        [0] = false, -- Compacts
        [1] = false, -- Sedans
        [2] = false, -- SUVs
        [3] = false, -- Coupes
        [4] = false, -- Muscle
        [5] = false, -- Sports Classics
        [6] = false, -- Sports
        [7] = false, -- Super
        [8] = true, -- Motorcycles
        [9] = false, -- Off-road
        [10] = false, -- Industrial
        [11] = false, -- Utility
        [12] = false, -- Vans
        [13] = true, -- Cycles
        [14] = true, -- Boats
        [15] = false, -- Helicopters
        [16] = false, -- Planes
        [17] = false, -- Service
        [18] = false, -- Emergency
        [19] = false, -- Military
        [20] = false, -- Commercial
        [21] = false, -- Trains
        [21] = false, -- Open Wheels
    },
    vehicleModels = {
        -- [`adder`] = false,
    }
}

-- Blacklist for Vehicle Classes or and Models. Set each to true for blacklisting 
Config.Blacklist = {
    showVehicle = true, -- if true show the blacklisted vehicles in the locksmith menu
    vehicleClasses = {
        [0] = false, -- Compacts
        [1] = false, -- Sedans
        [2] = false, -- SUVs
        [3] = false, -- Coupes
        [4] = false, -- Muscle
        [5] = false, -- Sports Classics
        [6] = false, -- Sports
        [7] = false, -- Super
        [8] = false, -- Motorcycles
        [9] = false, -- Off-road
        [10] = false, -- Industrial
        [11] = false, -- Utility
        [12] = false, -- Vans
        [13] = false, -- Cycles
        [14] = false, -- Boats
        [15] = false, -- Helicopters
        [16] = false, -- Planes
        [17] = false, -- Service
        [18] = false, -- Emergency
        [19] = false, -- Military
        [20] = false, -- Commercial
        [21] = false, -- Trains
        [21] = false, -- Open Wheels
    },
    vehicleModels = {
        -- [`adder`] = false,
    }
}

Config.WhitelistVehicles = { -- vehicles that dont need any key and can be used by anyone
    allowLocking = false, -- if you want users to be able to lock the vehicle ( would be useless as anyone can lock and unlock )
    models = {
        `ambulance`,
    },
    plates = {
        'ABC 123'
    }
}

-- Vehicles that dont need any key. Usefull for jobs
Config.JobVehicles = {
    ['cardealer'] = {
        models = {
        },
        plates = {
            'CADEALER'
        }
    },
    -- ['ambulance'] = {
    --     models = {
    --         `ambulance`,
    --         `emscharger`
    --     },
    --     plates = {
    --         'ABC 123'
    --     }
    -- }
}