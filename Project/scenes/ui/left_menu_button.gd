extends Button

var locked: bool = false

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var bip: AudioStreamPlayer

func _on_mouse_entered() -> void:
	if !locked:
		doTween(90)
		bip.play()
func _on_mouse_exited() -> void:
	if !locked:
		doTween(0)

func doTween(xPos: int) -> Tween:
	var tween: Tween
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "position:x", xPos, 0.2)
	return tween

func hideSelf() -> void:
	anim.play("hide")

func showSelf() -> void:
	anim.play("show")
