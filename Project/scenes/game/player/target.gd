extends Node2D

signal posChanged(pos: Vector2)

@onready var cam: Camera2D = $".."
@export var prog: ProgressBar

func _process(_delta: float) -> void:
	#rotation += 0.02
	position = get_viewport(
			).get_mouse_position(
			) + Vector2(
			-480,
			-270 +
			cam.get_screen_center_position().y -
			cam.global_position.y)
	posChanged.emit(position - Vector2(0, 24))

func updateCooldownReticle(time: float, maxTime: float) -> void:
	prog.max_value = maxTime
	prog.value = maxTime - time
	if prog.value >= maxTime:
		var flashTween := create_tween().set_parallel(true)
		flashTween.tween_property(prog, "modulate:r", 0.0, 0.01)
		flashTween.tween_property(prog, "modulate:b", 0.0, 0.01)
		flashTween.chain()
		flashTween.tween_property(prog, "modulate:r", 1.0, 0.2)
		flashTween.tween_property(prog, "modulate:b", 1.0, 0.2)
