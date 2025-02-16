class_name Dialogue_Object
extends Resource

@export var text: String
@export var portrait: Texture2D
@export var options: Array[Dialogue_Option]

#Optional
@export var next: Dialogue_Object
@export var action: String
@export var parameters: Array[Variant]

var phOptions: Array[Dialogue_Option] = [load("res://resources/dialogue/invalid/o1.tres")]

func _init(
		p_text = "",
		p_portrait = load("res://assets/images/characters/portrait/coomer.png"),
		p_options = phOptions,
		p_next = load("res://resources/dialogue/invalid/d1.tres"),
		p_action = "",
		p_parameters = []):
	text = p_text
	portrait = p_portrait
	options = p_options
	next = p_next
	action = p_action
	parameters = p_parameters

func _ready() -> void:
	if text == "":
		text = "DIALOGUE_%s" % [get_path().trim_prefix("res://resources/dialogue/").trim_suffix(".tres")]
