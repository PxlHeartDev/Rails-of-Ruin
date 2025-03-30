extends MarginContainer

@export var bip2: 					AudioStreamPlayer

@export_group("Buttons")
@export var audioButton: 			Button
@export var videoButton: 			Button
@export var controlsButton: 			Button
@export var accessibilityButton: 	Button
@export var backButton: 				Button

@export_group("Tabs")
@export var audioTab: 				MarginContainer
@export var videoTab: 				MarginContainer
@export var controlsTab: 			MarginContainer
@export var accessibilityTab: 		MarginContainer

@export_group("Animation Players")
@export var anim: 					AnimationPlayer


var locked: bool = false:
	set(val):
		locked = val
		audioButton.locked = val
		videoButton.locked = val
		controlsButton.locked = val
		accessibilityButton.locked = val
		backButton.locked = val

func _ready() -> void:
	locked = true
	anim.play("RESET")
	setButtonsState(false)
	visible = false

func open() -> void:
	setButtonsState(true)
	show()
	anim.play("RESET")

func setButtonsState(state: bool) -> void:
	audioButton.disabled = !state
	videoButton.disabled = !state
	controlsButton.disabled = !state
	accessibilityButton.disabled = !state
	backButton.disabled = !state
	locked = !state

#############
## Buttons ##
#############

signal back

func _on_audio_pressed() -> void:
	_on_any_pressed()
	await anim.animation_finished
	audioTab.appear()

func _on_video_pressed() -> void:
	_on_any_pressed()
	await anim.animation_finished
	videoTab.appear()

func _on_controls_pressed() -> void:
	_on_any_pressed()
	await anim.animation_finished
	controlsTab.appear()

func _on_accessibility_pressed() -> void:
	_on_any_pressed()
	await anim.animation_finished
	accessibilityTab.appear()

func _on_any_pressed() -> void:
	anim.play("hide")
	setButtonsState(false)
	locked = true
	bip2.play()

func _on_back_pressed() -> void:
	_on_any_pressed()
	await anim.animation_finished
	hide()
	back.emit()

func _on_any_tab_back_pressed() -> void:
	open()
	anim.play("show")
