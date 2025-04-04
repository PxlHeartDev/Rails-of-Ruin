class_name Weapon
extends Node2D

signal shot
signal cdTimeUpdated(time: float, maxTime: float)

@export var sprite: Sprite2D
@export var cooldown: Timer
@onready var game: Node2D = get_parent().get_parent().get_parent()

@export var bullet: PackedScene

var targetPos: Vector2

var disabled: bool = false

func _process(delta: float) -> void:
	cdTimeUpdated.emit(cooldown.time_left, cooldown.wait_time)

func _input(event: InputEvent) -> void:
	if disabled or !cooldown.is_stopped():
		return
	if event.is_action_pressed("shoot"):
		fireBullet()
		cooldown.start()
		shot.emit()

func fireBullet() -> void:
	var b = bullet.instantiate().duplicate()
	b.global_position = global_position
	b.damage = 1.0
	game.add_child(b)
	b.fire(targetPos - position, false)

func targetChanged(pos: Vector2) -> void:
	if disabled:
		return
	if pos.x < 0:
		flipSprite(true)
		rotation = -position.angle_to_point(Vector2(-pos.x, pos.y))
	else:
		rotation = position.angle_to_point(pos)
		flipSprite(false)
	targetPos = pos

func flipSprite(flip: bool) -> void:
	if game.isGravityFlipped:
		sprite.flip_h = !flip
	else:
		sprite.flip_h = flip
