extends Node2D

@export var cam: Camera2D
@export var saveNum: int
@onready var overlay: Node2D = $Overlay
@onready var exploration: Node2D = $Exploration
@onready var player: CharacterBody2D = $PlayerExplorer

func _ready() -> void:
	playerToSurface(exploration.get_child(1).getReliefAt(0))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_overlay"):
		overlay.active = !overlay.active
	elif event.is_action_pressed("cam_zoomIn"):
		cam.zoom += Vector2(0.1, 0.1)
	elif event.is_action_pressed("cam_zoomOut"):
		cam.zoom -= Vector2(0.051, 0.051)
	cam.zoom = clamp(cam.zoom, Vector2(0.05, 0.05), Vector2(3.0, 3.0))

#func _process(delta: float) -> void:
	#var cameraMotion = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	#if Input.is_action_pressed("cam_fast"):
		#cameraMotion *= 2.0
	#cam.position += cameraMotion * 50

func playerToSurface(surfaceLevel: int) -> void:
	player.position.y = surfaceLevel

func enterExploration() -> void:
	pass

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
