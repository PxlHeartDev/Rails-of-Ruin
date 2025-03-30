class_name Bullet
extends CharacterBody2D

@export var sprite: Sprite2D
@export var decayTimer: Timer
@export var attackComponent: Attack_Component

@export var speed: int = 500
@export var decayTime: float = 2.0
var damage = 1.0

func _ready() -> void:
	decayTimer.wait_time = decayTime
	attackComponent.hitSomething.connect(hitSomething)

func fire(direction: Vector2, isEnemy: bool = false) -> void:
	velocity = speed * direction.normalized()
	sprite.rotation = direction.angle()
	decayTimer.start()
	attackComponent.attackDamage = damage
	if isEnemy:
		attackComponent.collision_layer += 4
		attackComponent.collision_mask += 0
	else:
		attackComponent.collision_layer += 8
		attackComponent.collision_mask += 16

func _physics_process(_delta: float) -> void:
	move_and_slide()

func hitSomething() -> void:
	pass

func die() -> void:
	queue_free()
	if !decayTimer.is_stopped():
		decayTimer.stop()

func _on_decay_timeout() -> void:
	die()

func _on_attack_component_body_entered(body: Node2D) -> void:	
	if body.is_in_group("materia"):
		var attack = Attack_Obj.new()
		attack.damage = attackComponent.attackDamage
		attack.knockbackStrength = attackComponent.knockbackStrength
		attack.attackSource = self
		body.get_parent().damage(attack)
		die()
