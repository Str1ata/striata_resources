client_script "@vrp_anim/client.lua" fx_version 'cerulean'
game 'gta5'

author 'Striata <striatashop@hotmail.com>'
description 'striata resources (Striata shop)'
version '1.5.0'

lua54 'yes'

client_scripts {
	"@vrp/lib/utils.lua",
	"config.lua",
	"resources/**/script_config.lua",
	"resources/**/client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
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
	"config.lua",
	"resources/**/script_config.lua"
}
