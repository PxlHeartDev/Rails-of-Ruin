class_name Dialogue_Option
extends Resource

@export var text: String
@export var icon: Texture2D

@export var next: Dialogue_Object

#Optional
@export var action: String
@export var parameters: Array[Variant]

func _init(p_text = "",
p_icon = load("res://assets/images/characters/portrait/coomer.png"),
p_next = null,
p_action = "",
p_parameters = []):
	text = p_text
	icon = p_icon
	next = p_next
	action = p_action
	parameters = p_parameters
