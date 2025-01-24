fx_version 'bodacious'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Striata Discord: (@StriatShop), E-mail: (striatashop@hotmail.com)'
description 'striata resources (Striata shop)'
version '2.1'

lua54 'yes'

shared_scripts { 
	"@vrp/lib/utils.lua",
	"functions.lua"
}

client_scripts {
	"client.lua",
	"client.js",
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