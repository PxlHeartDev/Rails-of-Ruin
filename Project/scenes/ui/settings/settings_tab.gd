class_name Settings_Tab
extends MarginContainer

@export var bip2: AudioStreamPlayer

@onready var backButton: TextureButton = $VBoxContainer/Title/Button/Back
@onready var anim: AnimationPlayer = $AnimationPlayer

signal back

func _ready() -> void:
	backButton.position = Vector2(868, 7)

func appear() -> void:
	anim.play("RESET")
	await anim.get_tree().process_frame
	show()
	anim.play("show")

func disappear() -> void:
	anim.play("hide")
	await anim.animation_finished
	hide()

func _on_back_pressed() -> void:
	bip2.play()
	disappear()
	await anim.animation_finished
	back.emit()
