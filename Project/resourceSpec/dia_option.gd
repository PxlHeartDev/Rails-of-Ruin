class_name Dialogue_Option
extends Resource

@export var text: String
@export var icon: Texture2D

@export var next: Dialogue_Object

#Optional
@export var actionSignalName: String

func _init(p_text = "",
p_icon = preload("res://assets/images/characters/portrait/coomer.png"),
p_next = load("res://resources/dialogue/invalid/d1.tres"),
p_action = self.get_script().get_path()):
	text = p_text
	icon = p_icon
	next = p_next
	actionSignalName = p_action
