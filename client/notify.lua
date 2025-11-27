Notify = {}

Notify.Type = {
    -- General
    ['no_blank_key'] = 'error',

    -- main.lua
    ['vehicle_locked'] = 'closed',
    ['vehicle_unlocked'] = 'open',
    ['no_key_for_vehicle'] = 'error',
    ['vehicle_not_defined'] = 'error',
    ['got_key_for_vehicle'] = 'success',
    ['lock_Blacklisted'] = 'warning',
    
    -- locksmith.lua
    ['bought_new_lock'] = 'success',
    ['no_money_for_lock'] = 'error',
    ['bought_new_key'] = 'success',
    ['no_money_for_key'] = 'error',
    ['no_vehicles'] = 'error',
    ['swap_lock_vehicle_blacklisted'] = 'error',
    ['buy_key_vehicle_blacklisted'] = 'error',
    
    -- engine.lua
    ['no_key_for_vehicle_engine'] = 'error',
    ['vehicle_engine_stopped'] = 'info',
    ['vehicle_engine_started'] = 'info',
    
    -- functions.lua
    ['created_key'] = 'success',

    -- modules/lockpicking.lua 
    ['vehicle__already_unlocked'] = 'info',
    ['lockpick_broke'] = 'warning',
    ['lockpick_vehicle_blacklisted'] = 'warning',

    -- modules/hotwire.lua
    ['not_in_vehicle'] = 'error',
    ['engine_already_on'] = 'error',
    ['engine_start_failed'] = 'error',
    ['hotwire_vehicle_blacklisted'] = 'warning',
}

function Notify.Send(title, msg, time, type)
    exports['okokNotify']:Alert(title, msg, time, type)
end