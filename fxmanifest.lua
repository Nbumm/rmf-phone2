fx_version 'cerulean'
game 'gta5'

author 'RMF-Core'
description 'iPhone-style Phone UI for FiveM'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/img/*.svg',
    'html/sounds/*.mp3',
    'html/sounds/*.wav'
}

dependencies {
    'rmf-core'
}

lua54 'yes'