extends Node2D

signal posChanged(pos: Vector2)

func _process(delta: float) -> void:
	rotation += 0.02

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = event.position - Vector2(480, 302)
		posChanged.emit(position)
