extends MarginContainer

signal play
signal settings
signal quit

@export var playButton: 		Button
@export var settingsButton: 	Button
@export var quitButton: 		Button

@export var bip2: 			AudioStreamPlayer
@export var music: 			AudioStreamPlayer
@export var anim: 			AnimationPlayer

func _on_play_pressed() -> void:
	if !locked:
		play.emit()
		_on_any_pressed()
		fadeMusic(-60.0, 2.0)

func _on_settings_pressed() -> void:
	if !locked:
		settings.emit()
		_on_any_pressed()

func _on_quit_pressed() -> void:
	if !locked:
		quit.emit()
		#await quitButton.curTween.finished
		_on_any_pressed()
		fadeMusic(-60.0, 3.0)
		
		await anim.animation_finished
		get_tree().quit()

func play_back() -> void:
	showButtons()

func settings_back() -> void:
	showButtons()


var locked: bool = false:
	set(val):
		locked = val
		playButton.locked = val
		settingsButton.locked = val
		quitButton.locked = val

func _on_any_pressed() -> void:
	bip2.play()
	hideButtons()
	locked = true

func hideButtons() -> void:
	playButton.disabled = true
	settingsButton.disabled = true
	quitButton.disabled = true
	
	anim.play("hide")

func showButtons() -> void:
	playButton.disabled = false
	settingsButton.disabled = false
	quitButton.disabled = false
	
	anim.play("show")
	
	await anim.animation_finished
	locked = false

var musicTween: Tween

func fadeMusic(vol: float, time: float) -> void:
	if musicTween and musicTween.is_running():
		musicTween.stop()
	musicTween = create_tween()
	musicTween.tween_property(music, "volume_db", vol, time)
