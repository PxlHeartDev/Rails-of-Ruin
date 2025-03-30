extends MarginContainer

@export var save1: 		Button
@export var save2: 		Button
@export var save3: 		Button
@export var save4: 		Button
@export var backButton: 	Button
@export var anim: 		AnimationPlayer

signal back

var locked: bool = false:
	set(val):
		locked = val
		save1.locked = val
		save2.locked = val
		save3.locked = val
		save4.locked = val
		backButton.locked = val

func _ready() -> void:
	locked = true
	anim.play("RESET")
	setButtonsState(false)
	visible = false

func setButtonsState(state: bool) -> void:
	save1.disabled = !state
	save2.disabled = !state
	save3.disabled = !state
	save4.disabled = !state
	backButton.disabled = !state
	locked = !state

func open() -> void:
	setButtonsState(true)
	show()
	anim.play("RESET")

func _on_1_pressed() -> void:
	loadGame(1)


func _on_2_pressed() -> void:
	loadGame(2)


func _on_3_pressed() -> void:
	loadGame(3)


func _on_4_pressed() -> void:
	loadGame(4)


func _on_back_pressed() -> void:
	anim.play("hide")
	setButtonsState(false)
	await anim.animation_finished
	hide()
	back.emit()

func loadGame(saveGame: int) -> void:
	pass
