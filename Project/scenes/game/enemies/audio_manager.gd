class_name AudioManager
extends Node2D

@export_group("Vars")
@export var bus: 	String = "Game SFX"
@export var debug: 	bool = false

var sounds: Dictionary[String, Sound] = {}

func _ready() -> void:
	# Prepool some sounds that are known to be needed
	for i in range(1, 4):
		prePool("res://assets/sfx/enemy/death/d%d.wav" % i, 4)

func _process(_delta: float) -> void:
	for s in sounds.values():
		pass

func playSound(sound: String, pos: Vector2) -> void:
	queue_redraw()
	# Sound exists, play from pool
	if sound in sounds.keys():
		var soundObj = sounds[sound]
		var player = soundObj.getPlayer()
		player.position = pos
		player.play()
	# Sound not found, create pool then play
	else:
		var soundObj = prePool(sound, 8)
		var player = soundObj.getPlayer()
		player.position = pos
		player.play()

# Create some audio players for the pool of a given sound
func prePool(sound: String, channels: int) -> Sound:
	if sound in sounds.keys():
		return null
	var soundObj = Sound.new(sound, channels)
	soundObj.playerCreated.connect(playerCreated)
	soundObj.createPlayers()
	sounds.get_or_add(sound, soundObj)
	
	return soundObj

# Added an audio player to the tree
func playerCreated(player: AudioStreamPlayer2D) -> void:
	add_child(player)

# Sound class, stores the audio file and players pool
class Sound:
	var soundFile: AudioStream
	var channels: int = 8
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
	
	# Create the pool
	func createPlayers() -> void:
		for p in channels:
			players[p] = AudioStreamPlayer2D.new()
			players[p].stream = soundFile
			players[p].bus = bus
			playerCreated.emit(players[p])
	
	# Retrieve the next player from the pool
	func getPlayer() -> AudioStreamPlayer2D:
		var player = players[cur]
		cur += 1
		if cur == channels - 1:
			cur = 0
		if player.playing:
			player.stop()
		return player

# Debug
func _draw() -> void:
	if !debug:
		return
	for s in sounds.values():
		for p in s.players:
			draw_circle(p.position, 4.0, Color(0.435, 0.612, 0.835, 0.514))
