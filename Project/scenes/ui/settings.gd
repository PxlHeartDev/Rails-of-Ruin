extends MarginContainer

@onready var anim: 					AnimationPlayer = $AnimationPlayer
@onready var audioButton: 			Button = $"H/1/Audio"
@onready var videoButton: 			Button = $"H/1/Video"
@onready var controlsButton: 		Button = $"H/1/Controls"
@onready var accessibilityButton: 	Button = $"H/1/Accessibility"
@onready var backButton: 			Button = $"H/1/Back"

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
	visible = true
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
	pass # Replace with function body.

func _on_video_pressed() -> void:
	pass # Replace with function body.

func _on_controls_pressed() -> void:
	pass # Replace with function body.

func _on_accessibility_pressed() -> void:
	pass # Replace with function body.

func _on_back_pressed() -> void:
	anim.play("hide")
	setButtonsState(false)
	await anim.animation_finished
	visible = false
	back.emit()
