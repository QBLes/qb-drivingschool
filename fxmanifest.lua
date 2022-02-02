fx_version 'adamant'
game 'gta5'

description 'QB Driving School'

version '1.0.4'

server_scripts {
	'config.lua',
	'server/main.lua'
}

client_scripts {

	'config.lua',
	'client/main.lua',
	'client/gui.lua',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/logo.png',
	'html/dmv.png',
	'html/styles.css',
	'html/questions.js',
	'html/scripts.js',
	'html/debounce.min.js'
}

