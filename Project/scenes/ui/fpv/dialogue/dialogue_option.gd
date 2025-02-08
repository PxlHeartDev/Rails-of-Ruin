class_name DialogueOption
extends Button

@export var option: Dialogue_Option
@onready var optionIcon: TextureRect = $TextureRect

@export var option_object: Dialogue_Option

signal selected(obj: Dialogue_Option)

func _on_pressed() -> void:
	selected.emit(option_object)
