extends Node2D

signal waveComplete

signal anomalyProcessed

# Value signals
signal anomalyIncoming
signal speedUpdated(newSpeed: float)
signal distanceUpdated(newDistance: float)
signal anomalySurvived(newCount: int)
signal enemyKilled(newCount: int)
signal fuelUpdated(newFuel: float)

@export_group("Nodes")
@export var cam: 			Camera2D
@export var player: 			Player
@export var gameUI: 			CanvasLayer
@export var enemies: 		Node2D
@export var anomalyManager: 	Node2D

@export_group("Details")
@export var saveNum: 	int

var isGravityFlipped: bool = false

####################
## Game Variables ##
####################

var anomalyCount: int:
	set(val):
		anomalyCount = val
		anomalySurvived.emit(val)
var distance: float = 0:
	set(val):
		distance = val
		distanceUpdated.emit(val)
var fuel: float = 0:
	set(val):
		fuel = val
		fuelUpdated.emit(val)
var speed: float = 0:
	set(val):
		speed = val
		speedUpdated.emit(val)
var enemiesKilled: int = 0:
	set(val):
		enemiesKilled = val
		enemyKilled.emit(val)
var turbo: bool = false

var enemyCount: int = 0:
	set(val):
		enemyCount = val
		if val == 0:
			waveComplete.emit()

var wavesLeft: int = 0
var level: int = 0

func _ready() -> void:
	player.game = self
	#loadLevel(load("res://scenes/game/levels/level.tscn"))
	
	# Game signals
	player.healthComponent.healthChanged.connect(gameUI.healthBar.changed)
	player.healthComponent.maxHealthChanged.connect(gameUI.healthBar.maxChanged)
	player.died.connect(playerDied)
	
	# UI signals
	anomalyIncoming.connect(gameUI.anomalyAlert)
	distanceUpdated.connect(gameUI.distanceUpdated)
	speedUpdated.connect(gameUI.speedUpdated)
	anomalySurvived.connect(gameUI.anomalySurvived)
	enemyKilled.connect(gameUI.enemyKilled)
	fuelUpdated.connect(gameUI.fuelUpdated)
	
	gameUI.anomalyCoveredScreen.connect(processAnomaly)
	anomalyProcessed.connect(gameUI.anomalyProcessingComplete.emit)
	
	# Anomaly manager signals
	anomalyManager.spawnEnemy.connect(spawnEnemy)
	
	anomalyCount = 1
	await get_tree().create_timer(2.0).timeout
	#anomalyIncoming.emit()
	
	anomalyManager.chooseAnomaly().call()

func playerDied() -> void:
	pass

func loadLevel(levelScene: PackedScene) -> void:
	if !levelScene or !levelScene.can_instantiate():
		print("Level %s not found or couldn't load" % level)
		level -= 1
		return
	
	gameUI.levelChanged(level)

func processAnomaly() -> void:
	await get_tree().create_timer(0.5).timeout
	anomalyProcessed.emit()

func nextLevel() -> void:
	player.nextLevel()
	level += 1
	loadLevel(load("res://scenes/game/levels/level_%s.tscn" % level))

func enemyDied(fuelVal: float) -> void:
	enemyCount -= 1
	enemiesKilled += 1
	fuel += fuelVal

func spawnEnemy(enemy: Enemy) -> void:
	if enemy == null:
		return
	enemy.died.connect(enemyDied)
	enemyCount += 1
	enemy.player = player
	enemy.position.y -= 400
	enemy.position.x += randi_range(-200, 200)
	enemy.position.y += randi_range(-50, 50)
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
	
	# Delete old nodes to prevent duplicates
	var oldNodes = get_tree().get_nodes_in_group("Saves")
	for node in oldNodes:
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
