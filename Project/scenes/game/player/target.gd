extends Node2D

signal posChanged(pos: Vector2)

@onready var cam: Camera2D = $".."

func _process(_delta: float) -> void:
	rotation += 0.02
	position = get_viewport(
			).get_mouse_position(
			) + Vector2(
			-480,
			-270 +
			cam.get_screen_center_position().y -
			cam.global_position.y)
	posChanged.emit(position - Vector2(0, 24))
