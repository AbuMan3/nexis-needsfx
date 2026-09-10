fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Nexis Development'
description 'Nexis Needs FX - spatial hunger and needs feedback for QBCore'
version '2.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/index.html',
    'web/app.js',
    'web/audio/*.ogg'
}

ui_page 'web/index.html'
