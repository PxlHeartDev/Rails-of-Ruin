extends Node2D

## Sequence signals
signal anomalyProcessed
signal anomalyIncoming
signal died

## Value signals
signal speedUpdated(newSpeed: float)
signal distanceUpdated(newDistance: float)
signal anomalySurvived(newCount: int)
signal enemyKilled(newCount: int)
signal fuelUpdated(newFuel: float)

## Exports
@export_group("Nodes")
@export var cam: Camera2D
@export var player: Player
@export var gameUI: CanvasLayer
@export var enemies: Node2D
@export var anomalyManager: AnomalyManager
@export var gameSpace: Node2D
@export var music: AudioStreamPlayer

@export_group("Details")
@export var saveNum: 	int


####################
## Game Variables ##
####################

var isGravityFlipped: bool = false

var anomalyCount: int:
	set(val):
		anomalyCount = val
		anomalySurvived.emit(val)
var distance: float = 0.0:
	set(val):
		distance = val
		distanceUpdated.emit(val)
var fuel: float = 0.0:
	set(val):
		fuel = val
		fuelUpdated.emit(val)
var speed: float = 100.0:
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
		if val == -1:
			enemyCount = 0
		elif val == 0:
			enemyCount = 0
			wave += 1
		else:
			enemyCount = val

var wave: int = 0:
	set(val):
		if val == -1:
			wave = 1
			anomalySurvived.emit(1)
		else:
			wave = val
			anomalySurvived.emit(val)
var wavesLeft: int = 0
var level: int = 0

func _ready() -> void:
	#loadLevel(load("res://scenes/game/levels/level.tscn"))
	
	setupPlayer()
	
	## UI signals
	anomalyIncoming.connect(gameUI.anomalyAlert)
	distanceUpdated.connect(gameUI.distanceUpdated)
	speedUpdated.connect(gameUI.speedUpdated)
	anomalySurvived.connect(gameUI.anomalySurvived)
	enemyKilled.connect(gameUI.enemyKilled)
	fuelUpdated.connect(gameUI.fuelUpdated)
	
	gameUI.completeLabelDone.connect(anomalyManager.timer.start)
	
	died.connect(gameUI.died)
	
	gameUI.anomalyCoveredScreen.connect(processAnomaly)
	anomalyProcessed.connect(gameUI.anomalyProcessingComplete.emit)
	
	## Anomaly manager signals
	anomalyManager.spawnEnemy.connect(spawnEnemy)
	anomalyManager.timer.timeout.connect(anomalyIncoming.emit)
	anomalySurvived.connect(anomalyManager.anomalySurvived)
	
	resetValues()

func _process(delta: float) -> void:
	distance += (speed * delta)/1000.0

func playerDied() -> void:
	gameUI.gameOver()
	died.emit()
	music.died()
	
	Engine.time_scale = 1.0

func setupPlayer() -> void:
	player.game = self
	
	## Signals
	player.healthComponent.healthChanged.connect(gameUI.healthBar.changed)
	player.healthComponent.maxHealthChanged.connect(gameUI.healthBar.maxChanged)
	player.died.connect(playerDied)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func resetValues() -> void:
	Engine.time_scale = 1.0
	
	anomalyCount = 0
	distance = 0.0
	fuel = 0.0
	speed = 100.0
	enemiesKilled = 0
	turbo = false
	enemyCount = -1
	wavesLeft = 0
	level = 0
	wave = -1

func loadLevel(levelScene: PackedScene) -> void:
	if !levelScene or !levelScene.can_instantiate():
		print("Level %s not found or couldn't load" % level)
		level -= 1
		return
	
	gameUI.levelChanged(level)

func processAnomaly() -> void:
	anomalyManager.chooseAnomaly().call()
	anomalyManager.spawnEnemies().call()
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
	enemy.died_sound.connect(gameSpace.enemyDied)
	enemyCount += 1
	enemy.player = player
	enemy.position.x = randf_range(anomalyManager.validSpawnMin.x, anomalyManager.validSpawnMax.x)
	enemy.position.y = randf_range(anomalyManager.validSpawnMin.y, anomalyManager.validSpawnMax.y)
	enemies.add_child(enemy)

func reAddGameSpace() -> void:
	gameSpace = load("res://scenes/game/game_space.tscn").instantiate()
	add_child(gameSpace)

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

func _on_game_ui_particles_complete() -> void:
	gameSpace.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_game_ui_again_pressed() -> void:
	resetValues()
	reAddGameSpace()
	player = gameSpace.get_child(0)
	setupPlayer()
	
	music.again()

func _on_game_ui_quit_pressed() -> void:
	get_tree().root.add_child(load("res://globals/main.tscn").instantiate())
	
	music.quit()
	
	await gameUI.quitFadeComplete
	queue_free()
