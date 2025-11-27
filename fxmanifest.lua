fx_version 'bodacious'
game 'gta5'

author 'Max - TrymTube#5464'
description 'Vehicle Car Keys'
version '1.10'

lua54 'yes'

shared_script {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'shared/*.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'vehiclenames.lua',
	'client/**/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

escrow_ignore {
	'**/*.*',
	'*.*'
}
dependency '/assetpacks'