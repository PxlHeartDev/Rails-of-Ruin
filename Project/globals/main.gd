class_name Main
extends Node2D

enum STATE {
	MENU,
	GAME,
	PAUSED,
}

var state: STATE = STATE.MENU

@export var ui: UI
@export var fade: ColorRect
@export var screen: ColorRect
@export var updateAlert: MarginContainer
@export var updateAlertText: Label

var fadeTween: Tween

func _ready() -> void:
	fade.show()
	fadeIn(0.5)
	
	ui.mainMenu.play.connect(play)
	ui.mainMenu.settings.connect(settings)
	ui.mainMenu.quit.connect(quit)
	
	ui.settings.back.connect(ui.mainMenu.settings_back)
	ui.saveSelect.back.connect(ui.mainMenu.play_back)
	
	if Config.updated:
		updateAlert.show()
		updateAlertText.text = tr("MENU_updated") % [Config.oldVer, Config.newVer]

func play() -> void:
	fadeOut(1.0)
	await fadeTween.finished
	await get_tree().process_frame
	ui.hide()
	get_tree().root.add_child(load("res://scenes/game/game.tscn").instantiate())
	fadeIn(1.0)
	await fadeTween.finished
	queue_free()
	
	#ui.saveSelect.open()
	#await ui.mainMenu.anim.animation_finished
	#ui.saveSelect.anim.play("show")

func settings() -> void:
	ui.settings.open()
	if state == STATE.MENU:
		await ui.mainMenu.anim.animation_finished
	ui.settings.anim.play("show")

func quit() -> void:
	fadeOut(1.0)

func fadeIn(time: float) -> void:
	if fadeTween and fadeTween.is_running():
		fadeTween.stop()
	fadeTween = create_tween()
	fadeTween.tween_property(fade, "modulate:a", 0.0, time)

func fadeOut(time: float) -> void:
	if fadeTween and fadeTween.is_running():
		fadeTween.stop()
	fadeTween = create_tween()
	fadeTween.tween_property(fade, "modulate:a", 1.0, time)

func _on_update_ok_button_pressed() -> void:
	updateAlert.hide()
