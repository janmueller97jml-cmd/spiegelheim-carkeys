# Framework

mx_carkeys is dependend on **[ESX Legacy](https://github.com/esx-framework/esx-legacy)**.

# Installation

**[mx Development Docs](https://mx-developement.gitbook.io/mx-dev/installation-guides/mx_carkeys)**


# Features

### Unique Keys

- Each Vehicle and Key has a Unique Lock ID, that way it recognizes the correct key for each individual vehicle.
- Each Lock can be changed without having to change the plate thanks to the LockID

### Job-Based Vehicle Ownership (Keyless Access)

- Vehicles whose `owner` column in the database matches a player's job name are automatically keyless for that player
- Players with matching jobs can lock/unlock and toggle engine on/off without needing a physical key item
- Enable/disable with `Config.JobOwnerIsKeyless` (default: true)
- Configure the owner column name with `Config.JobOwnerColumnName` (default: 'owner')
- Example: A vehicle with `owner = 'police'` in `owned_vehicles` will be keyless for all players with job name 'police'

### Blacklist

- In the Config is a well customisable Blacklist. You can add either Vehicle Classes or/and individual models 

### Lockpick and Hotwire

- lockpicking vehicles is also possible. just use a item at a vehicle and there you go.
- cant start the engine? Hotwire it! But you can also disable the need for keys in the config
- Vehicles and Vehicle Classes can also be blacklisted from Hotwiring and/or Lockpicking

### Locksmith

- you can add as many Locksmiths as you want in Los Santos.
- the Locksmith can change the Lock but also can re create a key for you

## Changelog

Version 1.11.0
   - Replaced model/plate-based job and whitelist vehicle configuration with database-based job ownership
   - Removed `Config.JobVehicles` and `Config.WhitelistVehicles`
   - Added `Config.JobOwnerIsKeyless` to enable/disable job-based keyless access (default: true)
   - Added `Config.JobOwnerColumnName` to configure the owner column name (default: 'owner')
   - Vehicles with owner matching player's job name are now automatically keyless
   - Players with matching job can lock/unlock and toggle engine without a key item

Version 1.10.4
   - fixed script not working with some specific licenseplate formats
      - Credits to @.cemt (Dennis)

Version 1.10.3
   - added Config option for new AdvancedParking export
      - Config.AdvancedParking

Version 1.10.2
   - hotfix for QS Inventory Version not working

Version 1.10.1
   - hotfix for Config.JobVehicles not working

Version 1.10.0
   - opened some client side files for easier support
   - added Compatibility for multiple Databases
      - added Config.DefaultDatabase
      - added Config.Databases
   - added Config.BlankKeyItem
   - added Config.PlayLockSound
   - added 2 export
      - exports['mx_carkeys']:giveCarKey(vehicle, plate, count, removeBlankKey)
      - exports['mx_carkeys']:changeLock(vehicle, plate, count, removeBlankKey)
   - changed 1 export
      - exports['mx_carkeys']:giveCarKey(vehicle, plate, count) --> exports['mx_carkeys']:buyVehicle(vehicle, plate, count)
         - please consider this and change all old exports to the current ones
   - fixed some Vehicle Lock Effects

Version 1.9.0
   - added Admin Carkey
   - added Config.RenameItem, renames the Key to the Vehicle Licenseplate
   - removed aduty bypass

Version 1.8.3
   - added Config.QSInventoryV2 back again / my bad ^^      
   - fixed giving key when "vehicle" not defined - testing

Version 1.8.2
   - fixed door and lock sound, car light when using vehicle lock

Version 1.8.1
   - fixed removeKey export

Version 1.8.0
   - added Config option to disable each shown metadata information on key
   - added Config option ESXMenuAlign to change the position of the menu 
   - added Config option Config.Menu to change the menu you want to use 

   - added print when using Config.BypassAdutyEngineCheck without having the mx_aduty resource
   - added new menu / "oxContextMenu"

Version 1.7.0
   - added 1 export
      - exports['mx_carkeys']:removeVehicleKey(vehicle)

Version 1.6.0
   - added Lock Blacklist - usefull for bikes, boats and cycles

Version 1.5.0
   - added 1 event
      - TriggerEvent('mx_carkeys:client:giveCarKey', vehicle, plate, count)
      - TriggerClientEvent('mx_carkeys:client:giveCarKey', -1, vehicle, plate, count)

Version 1.4.0
   - added 1 event
      - TriggerEvent('mx_carkeys:client:setEngineStatus', vehicle, status)
      - TriggerClientEvent('mx_carkeys:client:setEngineStatus', -1, vehicle, status)

Version 1.3.2
   - now really fixed exports['mx_carkeys]:hasVehicleKey(vehicle)

Version 1.3.1
   - fixed exports['mx_carkeys]:hasVehicleKey(vehicle)

Version 1.3.0
   - added 2 exports
      - exports['mx_carkeys']:GetEngineStatus(vehicle)
      - exports['mx_carkeys']:SetEngineStatus(vehicle, status)

Version 1.2.0
   - added Support for QS Inventory V2

Version 1.1.0
   - added mx_aduty compatibility to start engine when in aduty even without keys
   - added export `exports['mx_carkeys']:hasVehicleKey()` checks if a player has the correct key for the vehicle

Version 1.0.2
   - fixed "bad argument #1 to 'remove' (position out of bounds)"

Version 1.0.1
   - added a wait when buying a vehicle to give the key and enter the lockID in the Database