class_name Dialogue_Object
extends Resource

@export var text: String
@export var portrait: Texture2D
@export var options: Array[Dialogue_Option]

#Optional
@export var actionSignalName: String

var phOptions: Array[Dialogue_Option] = [load("res://resources/dialogue/invalid/o1.tres")]

func _init(p_text = "",
p_portrait = preload("res://assets/images/characters/portrait/coomer.png"),
p_options = phOptions,
p_action = self.get_script().get_path()):
	text = p_text
	portrait = p_portrait
	options = p_options
	actionSignalName = p_action
	print(p_action)
