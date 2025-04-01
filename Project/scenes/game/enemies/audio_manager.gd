class_name AudioManager
extends Node2D

@export_group("Vars")
@export var channelsPerSound: 	int = 32
@export var bus: 				String = "Game SFX"

var sounds: Dictionary[String, Sound] = {}

func playSound(sound: String, pos: Vector2):
	if sound in sounds.keys():
		var soundObj = sounds[sound]
		var player = soundObj.getPlayer()
		player.position = pos
		player.play()
	else:
		var soundObj = Sound.new(sound, 8)
		soundObj.playerCreated.connect(playerCreated)
		soundObj.createPlayers()
		sounds.get_or_add(sound, soundObj)
		var player = soundObj.getPlayer()
		player.position = pos
		player.play()

func playerCreated(player: AudioStreamPlayer2D) -> void:
	add_child(player)

class Sound:
	var soundFile: AudioStream
	var channels: int = 4
	var players: Array[AudioStreamPlayer2D] = [] as Array[AudioStreamPlayer2D]
	var cur: int = 0
	var numSimul: int = 0
	var bus: String = "Game SFX"
	
	signal playerCreated(player: AudioStreamPlayer2D)
	
	func _init(
		_soundFile: String,
		_channels: int = 4,
	):
		soundFile = load(_soundFile)
		channels = _channels
		players.resize(channels)
	
	func createPlayers() -> void:
		for p in channels:
			print(p)
			players[p] = AudioStreamPlayer2D.new()
			players[p].stream = soundFile
			players[p].bus = bus
			playerCreated.emit(players[p])
	
	func getPlayer() -> AudioStreamPlayer2D:
		var player = players[cur]
		cur += 1
		if cur == channels - 1:
			cur = 0
		if player.playing:
			player.stop()
		return player
