Config = {}
Config.scriptsConfig = {}

Config.token = ""  -- Coloque Sua Licença

Config.framework = "auto"  -- auto, vrp, esx, qbcore

Config.Language = "pt-BR" -- altere a linguagem aqui! Linguagens disponiveis: (en-US | pt-BR)

--################################################--
--################# Resources ####################--
--################################################--
Config.resources = {  -- Defina true para ativar um resuorce e false para desativar.

	["striata_time-weather"]			= false,
	["striata_admprision"]				= false,
	["striata_robberies"]				= false,
	["striata_doors"]					= false,
	["striata_level"]					= false,
	["striata_group-manager"]			= false,
	["striata_notify"]					= false,
	["striata_survival"]				= false,
	["striata_production"]				= false,
	["striata_races"]					= false,

}

Config.orderedResources = { 
	["striata_truck"]					= false,
}

Config.notifysTypes = {
	success = "sucesso",
	denied = "negado",
	warning = "aviso",
	important = "importante",
}