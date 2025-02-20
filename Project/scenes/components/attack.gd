class_name Attack_Component
extends Area2D

@export_group("Vars")
@export var attackDamage: 		float
@export var knockbackStrength: 	float
@export var active: 				bool = true
@export var stunTime:			float

@export_group("Nodes")
@export var manager: ComponentManager

var collisionShapes: Array[Node2D]

func _ready():
	if !manager:
		var p = get_parent() 
		if p is ComponentManager:
			manager = p
		if !p:
			print("Error, hitbox component has no manager set")
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			collisionShapes.append(c)
	if active:
		enable()
	else:
		disable()

func _on_area_entered(area):
	if area is HitBox_Component:
		var hitBox: HitBox_Component = area
		
		var attack = Attack_Obj.new()
		attack.damage = attackDamage
		attack.knockbackStrength = knockbackStrength
		attack.attackSource = manager.parent
		
		var direction = manager.parent.global_position - hitBox.global_position
		if manager.parent is CharacterBody2D:
			manager.parent.velocity = direction.normalized() * 200
		if hitBox.manager.parent.has_method("stun"):
			hitBox.manager.parent.stun(stunTime)
		
		hitBox.damage(attack)
		if manager.parent is Bullet:
			manager.die()

func disable():
	for c in collisionShapes:
		c.set_deferred("disabled", true)

func enable():
	for c in collisionShapes:
		c.set_deferred("disabled", false)
