extends Button

var locked: bool = false:
	set(val):
		locked = val

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var bip: AudioStreamPlayer

func _on_mouse_entered() -> void:
	if !locked:
		doTween(90)
		bip.play()
func _on_mouse_exited() -> void:
	if !locked:
		doTween(0)

func doTween(xPos: int, time: float = 0.2) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:x", xPos, time)
	return tween

func hideSelf() -> void:
	anim.play("hide")

func showSelf() -> void:
	anim.play("show")


func _on_pressed() -> void:
	doTween(0, 0.15)
