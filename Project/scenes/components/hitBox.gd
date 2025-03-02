class_name HitBox_Component
extends Area2D

@export var manager: ComponentManager
@export var healthComponent: Health_Component

var collisionShapes: Array[Node2D]

var disabled := false

func _ready() -> void:
	if !manager:
		var p = get_parent() 
		if p is ComponentManager:
			manager = p
		if !p:
			print("Error, hitbox component has no manager set")
	if !manager.is_node_ready():
		await manager.ready
	if !(manager.parent is Bullet):
		if !healthComponent:
			healthComponent = manager.get_node("Health_Component")
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			collisionShapes.append(c)

func hit() -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer in [4, 8]:
		manager.die()

func _on_body_entered(body: Node2D) -> void:
	if body.collision_layer == 32:
		manager.die()

func damage(attack: Attack_Obj) -> void:
	if disabled:
		return
	if healthComponent:
		healthComponent.damage(attack.damage)
	if manager.parent.has_method("damage"):
		manager.parent.damage(attack)

func disable():
	disabled = true
	for c in collisionShapes:
		c.set_deferred("disabled", true)

func enable():
	disabled = false
	for c in collisionShapes:
		c.set_deferred("disabled", false)
