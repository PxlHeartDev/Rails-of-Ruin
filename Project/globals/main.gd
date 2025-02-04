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

var fadeTween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.show()
	fadeIn(0.5)
	
	ui.mainMenu.play.connect(play)

func play() -> void:
	state = STATE.GAME
	fadeOut(0.5)
	ui.updateBG(load("res://assets/images/backgrounds/triton.jpg"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
