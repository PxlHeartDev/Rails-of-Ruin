class_name Weapon
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var game: Node2D = get_parent().get_parent().get_parent()

@export var bullet: PackedScene

var targetPos: Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var b = bullet.instantiate().duplicate()
		b.global_position = global_position
		b.damage = 1.0
		game.add_child(b)
		b.fire(targetPos - position, false)

func targetChanged(pos: Vector2) -> void:
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
