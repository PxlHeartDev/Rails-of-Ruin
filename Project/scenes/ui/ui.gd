class_name UI
extends Control

@export var bg: TextureRect
@export var fade: ColorRect
@export var mainMenu: MarginContainer
@export var settings: MarginContainer

var tween: Tween

var bgImages: Array[String] = []

func _ready() -> void:
	var dir := DirAccess.open("res://assets/images/backgrounds")
	for f in dir.get_files():
		if !f.contains(".import"):
			bgImages.append(f)

func updateBG(img: Texture2D) -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	tween.tween_property(bg, "texture", img, 0.0)
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)

var curBG = 0

func _on_bg_cycling_timeout() -> void:
	var newBGIndex = 0
	while newBGIndex == curBG:
		newBGIndex = randi_range(0, len(bgImages)-1)
	curBG = newBGIndex
	updateBG(load("res://assets/images/backgrounds/%s" % bgImages[curBG]))
