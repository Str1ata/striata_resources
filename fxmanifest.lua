fx_version 'bodacious'
game 'gta5'

author 'Striata <striatashop@hotmail.com>'
description 'striata resources (Striata shop)'
version '2.0'

lua54 'yes'

shared_scripts { 
	"@vrp/lib/utils.lua",
	"functions.lua"
}

client_scripts {
	"client.lua",
	"resources/**/script_config.lua",
	"resources/**/client.lua"
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server.lua",
	"resources/**/script_config.lua",
	"resources/**/server.lua"
}

ui_page 'html/index.html'

files {
	"config.json",
	"resources/**/script_config.lua",
	"html/**",
	"resources/**/html/**"
}