class_name Attack_Component
extends Area2D


@export_group("Vars")
@export var attackDamage: 		float
@export var knockbackStrength: 	float
@export var active: 				bool
@export var stunTime:			float

@export_group("Nodes")
@export var rootNode: Node2D

var collisionShapes: Array[Node2D]

func _ready():
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
		attack.attackSource = rootNode
		
		var direction = rootNode.global_position - hitBox.global_position
		if rootNode is CharacterBody2D:
			rootNode.velocity = direction.normalized() * 200
		if hitBox.rootNode.has_method("stun"):
			hitBox.rootNode.stun(stunTime)
		
		hitBox.damage(attack)

func disable():
	for c in collisionShapes:
		c.set_deferred("disabled", true)

func enable():
	for c in collisionShapes:
		c.set_deferred("disabled", false)
