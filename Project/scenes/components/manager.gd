class_name ComponentManager
extends Node2D

@export var parent: Node

func _ready() -> void:
	if !parent:
		var p = get_parent()
		if !p:
			print("Error, component manager has no parent set")
		else:
			parent = p

func die():
	if parent.has_method("die"):
		parent.die()
	else:
		print("'die' function not found on %s" % parent)
