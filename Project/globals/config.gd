extends Node

var config = ConfigFile.new()
var err = config.load("user://config.cfg")
var firstBoot: bool = false

# `path` param is passed as "section/key"

func _ready() -> void:
	if err != OK:
		initPlayerSettings()
		firstBoot = true

func initPlayerSettings() -> void:
	updateSetting("audio/Master", 0.0, false)
	updateSetting("audio/Music", 0.0, false)
	updateSetting("audio/Game_SFX", 0.0, false)
	updateSetting("audio/Menu_SFX", 0.0, true)

func retrieveSetting(path: String) -> Variant:
	var splitPath = path.split("/")
	return config.get_value(splitPath[0], splitPath[1])

func updateSetting(path: String, value: Variant, save = true) -> void:
	var splitPath = path.split("/")
	config.set_value(splitPath[0], splitPath[1], value)
	if save:
		config.save("user://config.cfg")
