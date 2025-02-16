class_name Attack_Obj
extends Resource

@export_group("Vars")
var damage: float
var knockbackStrength: float

@export_group("Nodes")
var attackSource: Node2D

func sourcePos():
	return attackSource.global_position
