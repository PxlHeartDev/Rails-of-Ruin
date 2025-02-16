extends Node2D

var roomGrid: Dictionary

func _ready() -> void:
	var room = load("res://scenes/game/room.tscn").instantiate()
	room.roomSize = Vector2i(1, 1)
	room.scale.x = room.roomSize.x
	room.scale.y = room.roomSize.y
	placeRoom(room)
	var room2 = load("res://scenes/game/room.tscn").instantiate()
	room2.gridPos = Vector2i(2, 1)
	room2.roomSize = Vector2i(1, 2)
	room2.roomType = 1
	room2.scale.x = room2.roomSize.x
	room2.scale.y = room2.roomSize.y
	placeRoom(room2)
	
	print(roomGrid)
	#for x in 10:
		#for y in 10:
			#var room = load("res://scenes/game/room.tscn").instantiate()
			#room.roomSize = Vector2i(1, 1)
			#room.gridPos = Vector2i(x, y)
			#placeRoom(room)

func getRoom(pos: Vector2i) -> Room:
	var room: Variant = roomGrid[coordToKey(pos)]
	if room is Vector2i:
		room = roomGrid[coordToKey(room)]
	return room

func placeRoom(room: Room) -> void:
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			if Vector2i(room.gridPos.x + x, room.gridPos.y + y) == room.gridPos:
				roomGrid[coordToKey(room.gridPos)] = room
				continue
			roomGrid[coordToKey(Vector2(room.gridPos.x + x, room.gridPos.y + y))] = Vector2i(room.gridPos.x, room.gridPos.y)
	room.position = getWorldPosition(room.gridPos)
	add_child(room)

func getWorldPosition(gridPos: Vector2i) -> Vector2i:
	return gridPos * 200

func coordToKey(coord: Vector2i) -> String:
	return "%s,%s" % [coord.x, coord.y]

func keyToCoord(key: String) -> Vector2i:
	var splitKey = key.split(",")
	return Vector2i(int(splitKey[0]), int(splitKey[1]))

func isValidPlacement(room: Room) -> bool:
	return false

func saveSelf() -> void:
	pass

func loadSelf() -> void:
	pass
