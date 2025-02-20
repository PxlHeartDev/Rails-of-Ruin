extends Node
class_name State

@export_group("Nodes")
@export var enemy: Enemy

signal transitioned

func _ready() -> void:
	enemy = get_parent().enemy

func enter(prevState: String):
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physUpdate(_delta: float):
	pass
