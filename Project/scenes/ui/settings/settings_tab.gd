extends MarginContainer

@onready var anim: AnimationPlayer = $AnimationPlayer

signal back

func appear() -> void:
	anim.play("RESET")
	await anim.get_tree().process_frame
	show()
	anim.play("show")

func disappear() -> void:
	anim.play("hide")
	await anim.animation_finished
	hide()

func _on_back_pressed() -> void:
	disappear()
	await anim.animation_finished
	back.emit()
