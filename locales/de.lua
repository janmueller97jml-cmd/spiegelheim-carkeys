Locales['de'] = {
    -- General
    ['no_blank_key'] = 'Du hast keinen Blanken Auto Schlüssel',

    -- Metadata
    ['vehicle_plate'] = 'Kennzeichen',
    ['vehicle_model'] = 'Model',
    ['vehicle_lockID'] = 'Schlüssel ID',

    -- client/main.lua // Notification
    ['vehicle_locked'] = 'Das Fahrzeug ist nun Abgeschlossen',
    ['vehicle_unlocked'] = 'Das Fahrzeug ist nun Aufgeschlossen',
    ['vehicle_incorrect_key'] = 'Du hast nicht den richtigen Schlüssel',
    ['received_key'] = 'Du hast ein Schlüssel für das Fahrzeug %s erhalten',
    ['lock_Blacklisted'] = 'Fahrzeug kann nicht abgeschlossen werden',

    -- locksmith/locksmith.lua // Help Notification
    ['open_menu'] = 'Drücke ~INPUT_CONTEXT~ um das Menu zu Öffnen',

    -- locksmith/locksmith.lua // Notification
    ['no_vehicle'] = 'Du hast kein Fahrzeug in der Garage',
    ['changed_lock'] = 'Du hast Erfolgreich dein Schloss für $%s ausgetauscht',
    ['not_enough_money_lock'] = 'Du hast nicht genug Geld um das Schloss zu Tauschen',
    ['lock_blacklisted_vehicle'] = 'Das Fahrzeug ist Blacklisted du kannst dein Schloss nicht austauschen',
    ['bought_key'] = 'Du hast Erfolgreich einen neuen Schlüssel für $%s gekauft',
    ['not_enough_money_key'] = 'Du hast nicht genug Geld um einen Schlüssel zu kaufen',
    ['key_blacklisted_vehicle'] = 'Das Fahrzeug ist Blacklisted du kannst keinen Schlüssel Kaufen',
    
    -- locksmith/locksmith.lua // ox Target
    ['locksmith_menu'] = 'Schlosser Menu',

    -- functions.lua // Notifications
    ['created_key'] = 'Du hast ein Schlüssel hergestellt',

    -- locksmith/locksmith.lua // Menus
    ['buy_key'] = 'Schlüssel Kaufen',
    ['buy_key_description'] = "Kaufe dir einen weiteren Schlüssel",
    ['change_lock'] = 'Schloss Austauschen',
    ['change_lock_description'] = "Wechsel das Schloss von einem Fahrzeug",
    ['locksmith_title'] = 'Schlosser',
    ['change_lock_title'] = 'Schloss Austauschen',
    ['buy_key_title'] = 'Schlüssel Kaufen',
    ['blacklisted_vehicle'] = "Das Fahrzeug ist gesperrt",

    -- locksmith/locksmith.lua // Blip Name
    ['blip_title'] = 'Schlosser',

    -- functions.lua // Notifications
    ['created_key'] = 'Schlüssel erstellt',

    -- engine.lua // Notifications
    ['need_key'] = 'Du brauchst einen Schlüssel um dem Motor zu starten',
    ['vehicle_engine_started'] = 'Motor Eingeschaltet',
    ['vehicle_engine_stopped'] = 'Motor Ausgeschaltet',

    -- modules/lockpicking.lua // Title
    ['lockpick_progressbar_label'] = 'Fahrzeug wird Aufgebrochen',

    -- modules/lockpicking.lua // Notifications
    ['vehicle__already_unlocked'] = 'Fahrzeug ist bereits Offen',
    ['lockpick_broke'] = 'Dein Dietrich ist abgebrochen',
    ['lockpick_vehicle_blacklisted'] = 'Fahrzeug ist geblacklisted, du kannst dies nicht Aufbrechen',

    -- modules/hotwire.lua // Title
    ['hotwire_progressbar_label'] = 'Fahrzeug Kurzschließen',

    -- modules/hotwire.lua // Notifications
    ['not_in_vehicle'] = 'Du bist in keinem Fahrzeug',
    ['engine_already_on'] = 'Motor ist bereits Gestartet',
    ['engine_start_failed'] = 'Motor ist nicht Gestartet. Versuche es erneut',
    ['hotwire_vehicle_blacklisted'] = 'Fahrzeug ist geblacklisted, du kannst dies nicht Kurzschließen',
}