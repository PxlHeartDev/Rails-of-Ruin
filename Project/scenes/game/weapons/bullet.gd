class_name Bullet
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var decayTimer: Timer = $Decay

@export var speed: int = 500
@export var decayTime: float = 2.0

func _ready() -> void:
	decayTimer.wait_time = decayTime

func fire(direction: Vector2, isEnemy: bool = false) -> void:
	velocity = speed * Vector2.ZERO.direction_to(direction)#
	decayTimer.start()
	if isEnemy:
		collision_layer = 4
	else:
		collision_layer = 8

func _physics_process(delta: float) -> void:
	move_and_slide()

func die() -> void:
	queue_free()
	if !decayTimer.is_stopped():
		decayTimer.stop()

func _on_decay_timeout() -> void:
	die()
