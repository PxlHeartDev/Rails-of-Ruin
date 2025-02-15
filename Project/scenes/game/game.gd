extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var overlay: Node2D = $Overlay

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_overlay"):
		overlay.active = !overlay.active
	elif event.is_action_pressed("cam_zoomIn"):
		cam.zoom += Vector2(0.1, 0.1)
	elif event.is_action_pressed("cam_zoomOut"):
		cam.zoom -= Vector2(0.1, 0.1)
	cam.zoom = clamp(cam.zoom, Vector2(0.11, 0.11), Vector2(3.0, 3.0))

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var cameraMotion = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	if Input.is_action_pressed("cam_fast"):
		cameraMotion *= 2.0
	cam.position += cameraMotion * 50
