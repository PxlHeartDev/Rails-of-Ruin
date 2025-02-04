extends MarginContainer


signal play

@onready var playButton: Button = $"H/1/Play"
@onready var settingsButton: Button = $"H/1/Settings"
@onready var quitButton: Button = $"H/1/Quit"

@onready var anim: AnimationPlayer = $AnimationPlayer

func _on_play_pressed() -> void:
	play.emit()
	lockButtons()

func _on_settings_pressed() -> void:
	lockButtons()


func _on_quit_pressed() -> void:
	
	lockButtons()

var locked: bool = false

func lockButtons() -> void:
	playButton.disabled = true
	settingsButton.disabled = true
	quitButton.disabled = true
	locked = true


var playTween: 		Tween
var settingsTween: 	Tween
var quitTween: 		Tween

func _on_play_mouse_entered() -> void:
	if !locked:
		buttonHover(playButton, playTween)
func _on_play_mouse_exited() -> void:
	if !locked:
		buttonUnhover(playButton, playTween)

func _on_settings_mouse_entered() -> void:
	if !locked:
		buttonHover(settingsButton, settingsTween)
func _on_settings_mouse_exited() -> void:
	if !locked:
		buttonUnhover(settingsButton, settingsTween)

func _on_quit_mouse_entered() -> void:
	if !locked:
		buttonHover(quitButton, quitTween)
func _on_quit_mouse_exited() -> void:
	if !locked:
		buttonUnhover(quitButton, quitTween)

func buttonHover(button: Button, tween: Tween) -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(button, "position:x", 38, 0.2)

func buttonUnhover(button: Button, tween: Tween) -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(button, "position:x", 0, 0.2)
