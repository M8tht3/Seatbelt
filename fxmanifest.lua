fx_version 'cerulean'
games { 'gta5' }

author 'Zen Development'
description 'Updated seatbelt'
version '1.0.0'

lua54 'yes'

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client/main.lua',
}

server_scripts {
    'config.lua',
    'server/main.lua',
}

ui_page "client/html/index.html"

files {
    'client/html/index.html',
    'client/html/buckle.ogg',
    'client/html/unbuckle.ogg',
}
