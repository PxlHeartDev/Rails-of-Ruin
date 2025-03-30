extends Node

var config = ConfigFile.new()
var err = config.load("user://config.cfg")
var firstBoot: bool = false
var updated: bool = false

var oldVer: String
var newVer: String

# `path` param is passed as "section/key"

func _ready() -> void:
	if err == OK:
		if retrieveSetting("cfg/ver") != ProjectSettings.get_setting("application/config/version"):
			var saveDeaths = retrieveSetting("stats/deaths")
			oldVer = retrieveSetting("cfg/ver")
			newVer = ProjectSettings.get_setting("application/config/version")
			config.clear()
			initPlayerSettings()
			updateSetting("stats/deaths", saveDeaths)
			updated = true
	else:
		initPlayerSettings()
		firstBoot = true
	newVer = retrieveSetting("cfg/ver")

func initPlayerSettings() -> void:
	updateSetting("audio/Master", 0.0, false)
	updateSetting("audio/Music", 0.0, false)
	updateSetting("audio/Game_SFX", 0.0, false)
	updateSetting("audio/Menu_SFX", 0.0, false)
	
	updateSetting("stats/deaths", 0, false)
	
	updateSetting("cfg/ver", ProjectSettings.get_setting("application/config/version"), true)

func retrieveSetting(path: String) -> Variant:
	var splitPath = path.split("/")
	return config.get_value(splitPath[0], splitPath[1])

func updateSetting(path: String, value: Variant, save = true) -> void:
	var splitPath = path.split("/")
	config.set_value(splitPath[0], splitPath[1], value)
	if save:
		config.save("user://config.cfg")
