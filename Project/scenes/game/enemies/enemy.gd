class_name Enemy
extends CharacterBody2D

signal died

@export_group("Stats")
@export var speed: float = 	50.0

@export_group("Nodes")
@export var sprite: 			AnimatedSprite2D
@export var nav: 			NavigationAgent2D
@export var stateMachine: 	StateMachine
@export var attackComponent:	Attack_Component
@export var hitBoxComponent:	HitBox_Component
@export var col:				CollisionShape2D


@export_group("Timers")
@export var stunTimer: 		Timer

var player: Player

func _ready() -> void:
	player = get_parent().get_parent().player


func damage(attack: Attack_Obj) -> void:
	if attack.damage > 0:
		damageFlash()

func die() -> void:
	damageFlash()
	died.emit()
	stateMachine.die()
	attackComponent.disable()
	hitBoxComponent.disable()
	col.set_deferred("disabled", true)

func stun(time: float) -> void:
	stunTimer.start(time)

func damageFlash() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate:g", 0.0, 0.05)
	tween.tween_property(sprite, "modulate:b", 0.0, 0.05)
	tween.chain()
	tween.tween_property(sprite, "modulate:g", 1.0, 0.2)
	tween.tween_property(sprite, "modulate:b", 1.0, 0.2)
