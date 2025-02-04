class_name UI
extends Control

@export var bg: TextureRect
@export var fade: ColorRect
@export var mainMenu: Control

var tween: Tween

func updateBG(img: Texture2D) -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.25)
	tween.tween_property(bg, "texture", img, 0.0)
	tween.tween_property(fade, "modulate:a", 0.0, 0.25)
