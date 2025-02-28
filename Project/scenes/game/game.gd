extends Node2D

signal carriageComplete
signal waveComplete

@export_group("Nodes")
@export var cam: 		Camera2D
@export var player: 		Player
@export var gameUI: 		CanvasLayer
@export var enemies: 	Node2D

@export_group("Details")
@export var saveNum: 	int

var isGravityFlipped: bool = false

####################
## Game Variables ##
####################

var distance: int = 0
var fuel: int = 0
var speed: int = 0
var turbo: bool = false

var enemyCount: int = 0:
	set(val):
		enemyCount = val
		if val == 0:
			waveComplete.emit()
			if wavesLeft == 0:
				carriageComplete.emit()

var wavesLeft: int = 0
var level: int = 0

func _ready() -> void:
	#loadLevel(load("res://scenes/game/levels/level.tscn"))
	
	player.healthComponent.healthChanged.connect(gameUI.healthBar.changed)
	player.healthComponent.maxHealthChanged.connect(gameUI.healthBar.maxChanged)
	carriageComplete.connect(gameUI.carriageComplete)

func loadLevel(levelScene: PackedScene) -> void:
	if !levelScene or !levelScene.can_instantiate():
		print("Level %s not found or couldn't load" % level)
		level -= 1
		return
	#if curLevel:
		#curLevel.queue_free()
	#curLevel = levelScene.instantiate()
	#add_child.call_deferred(curLevel)
	#
	#player.position = curLevel.entrance.position
	#
	#curLevel.exit.playerExited.connect(nextLevel)
	#curLevel.spawnEnemy.connect(enemySpawned)
	#carriageComplete.connect(curLevel.exit.levelCleared)
	gameUI.levelChanged(level)

func nextLevel() -> void:
	player.nextLevel()
	level += 1
	loadLevel(load("res://scenes/game/levels/level_%s.tscn" % level))

func enemyDied() -> void:
	enemyCount -= 1

func enemySpawned(enemy: Enemy) -> void:
	enemy.died.connect(enemyDied)
	enemyCount += 1
	enemies.add_child(enemy)

func saveGame() -> void:
	var saveFile = FileAccess.open("user://save%s.save" % saveNum, FileAccess.WRITE)
	var nodesToSave = get_tree().get_nodes_in_group("Saves")
	
	for node in nodesToSave:
		if node.scene_file_path.is_empty():
			print("Saveable node '%s' is not an instanced scene, skipped" % node.name)
			continue
		
		if !node.has_method("save"):
			print("Saveable node '%s' is has no save() function, skipped" % node.name)
			continue
		
		var nodeData = node.call("save")
		
		var jsonString = JSON.stringify(nodeData)
		
		saveFile.store_line(jsonString)

func loadGame() -> void:
	if not FileAccess.file_exists("user://save%s.save" % saveNum):
		return # No save found
	
	var nodesToLoad = get_tree().get_nodes_in_group("Saves")
	for node in nodesToLoad:
		node.queue_free()
	
	var saveFile = FileAccess.open("user://save%s.save" % saveNum, FileAccess.READ)
	
	while saveFile.get_position() < saveFile.get_length():
		var jsonString = saveFile.get_line()
		
		var json = JSON.new()
		
		var parseResult = json.parse(jsonString)
		if parseResult != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
			continue
		
		var nodeData = json.data
		
		var newObject = load(nodeData["filename"]).instantiate()
		get_node(nodeData["parent"]).add_child(newObject)
		newObject.position = Vector2(nodeData["pos_x"], nodeData["pos_y"])
		
		for i in nodeData.keys():
			if i in ["filename", "parent", "pos_x", "pos_y"]:
				continue
			newObject.set(i, nodeData[i])
