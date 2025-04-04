extends Button

var locked: bool = false:
	set(val):
		locked = val

@export var anim: AnimationPlayer

@export var bip: AudioStreamPlayer

var curTween: Tween

func _on_mouse_entered() -> void:
	if !locked:
		doTween(45)
		bip.play()
func _on_mouse_exited() -> void:
	if !locked:
		doTween(0)

func doTween(xPos: int, time: float = 0.2) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "position:x", xPos, time)
	curTween = tween
	return tween

func hideSelf() -> void:
	if position.x > 44:
		anim.play("hidePressed")
	else:
		anim.play("hide")

func showSelf() -> void:
	anim.play("show")


#func _on_pressed() -> void:
	#doTween(0, 0.15)
