extends Node2D

@onready var rooms: Node2D = $"../Rooms"

var active: bool = false:
	set(val):
		active = val
		queue_redraw()

## Alternative overlay version with borders between squares
#func _draw() -> void:
	#var roomOriginList: Dictionary
	#for key in roomGrid.keys():
		#var colour: Color
		#if roomGrid[key] is Node2D:
			#roomOriginList[key] = roomGrid[key]
			#colour = roomGrid[key].getOverlayColour()
		#else:
			#colour = getRoom(keyToCoord(key)).getOverlayColour()
		#var coord: Vector2i
		#coord.x = int(key.split(",")[0])
		#coord.y = int(key.split(",")[1])
		#draw_rect(Rect2i(200+100*coord.x, 200+100*coord.y, 98, 98), colour)

func _draw() -> void:
	if !active:
		return
	for key in rooms.roomGrid.keys():
		var colour: Color
		var room = rooms.roomGrid[key]
		if room is Node2D:
			colour = room.getOverlayColour()
		else:
			continue
		var coord: Vector2i
		coord.x = int(key.split(",")[0])
		coord.y = int(key.split(",")[1])
		draw_rect(Rect2i(100*coord.x, 100*coord.y, 200*room.roomSize.x, 200*room.roomSize.y), colour)
