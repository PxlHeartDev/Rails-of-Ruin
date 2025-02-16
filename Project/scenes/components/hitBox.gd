class_name HitBox_Component
extends Area2D

@export var manager: ComponentManager

func _ready() -> void:
	if !manager:
		var p = get_parent() 
		if p is ComponentManager:
			manager = p
		if !p:
			print("Error, hitbox component has no manager set")

func hit() -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	if area.collision_layer in [4, 8]:
		manager.die()
