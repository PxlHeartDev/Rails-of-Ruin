class_name UI
extends Control

@export var bg: TextureRect
@export var fade: ColorRect
@export var mainMenu: MarginContainer
@export var saveSelect: MarginContainer
@export var settings: MarginContainer

@onready var p_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer

var tween: Tween

var bgImages: Array[String] = []

func _ready() -> void:
	var dir := DirAccess.open("res://assets/images/backgrounds")
	for f in dir.get_files():
		if !f.contains(".import"):
			bgImages.append(f)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		p_layer.motion_offset = (event.position - Vector2(960, 540))*-0.04

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
