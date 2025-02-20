extends Node2D


@export var cam: 		Camera2D
@export var saveNum: 	int
@export var player: 		Player

var isGravityFlipped: bool = false

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
