class_name Health_Component
extends Node2D

signal healthChanged(old: float, new: float)

@export var manager: ComponentManager
@export var health: float = 1.0
@export var maxHealth: float = 1.0

func _ready() -> void:
	if !manager:
		var p = get_parent() 
		if p is ComponentManager:
			manager = p
		if !p:
			print("Error, health component has no manager set")

func damage(dmg: float) -> void:
	var oldHealth = health
	health -= dmg
	if health <= 0:
		health = 0
		manager.die()
	healthChanged.emit(oldHealth, health)
