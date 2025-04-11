class_name Health_Component
extends Node2D

signal healthChanged(old: float, new: float)
signal maxHealthChanged(old: float, new: float)

@export var manager: ComponentManager
@export var health: float = 1.0:
	set(val):
		healthChanged.emit(health, val)
		health = val
@export var maxHealth: float = 1.0:
	set(val):
		maxHealthChanged.emit(maxHealth, val)
		maxHealth = val

func _ready() -> void:
	if !manager:
		var p = get_parent() 
		if p is ComponentManager:
			manager = p
		if !p:
			print("Error, health component has no manager set")
	await get_tree().process_frame
	healthChanged.emit(health, health)
	maxHealthChanged.emit(maxHealth, maxHealth)

func damage(dmg: float) -> void:
	#var oldHealth = health
	health -= dmg
	if health <= 0:
		health = 0
		manager.die()

func fullHeal() -> void:
	health = maxHealth
