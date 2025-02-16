class_name GameSave
extends Resource

@export var outpostResources: Array[OutpostResource]
@export var roomGrid: Dictionary

func _init(
		p_outpostResources = [],
		p_roomGrid = {}
		) -> void:
	outpostResources = p_outpostResources
	roomGrid = p_roomGrid
