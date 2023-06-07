fx_version 'bodacious'
game 'gta5'

author 'Striata <striatashop@hotmail.com>'
description 'striata resources (Striata shop)'
version '1.8'

lua54 'yes'

client_scripts {
	"@vrp/lib/utils.lua",
	"functions.lua",
	"config.lua",
	"client.lua",
	"resources/**/script_config.lua",
	"resources/**/client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	'@mysql-async/lib/MySQL.lua',
	"functions.lua",
	"config.lua",
	"server.lua",
	"resources/**/script_config.lua",
	"resources/**/server.lua"
}

ui_page 'html/index.html'

files {
	"html/**",
}      

escrow_ignore {
	"functions.lua",
	"config.lua",
	"resources/**/script_config.lua"
}