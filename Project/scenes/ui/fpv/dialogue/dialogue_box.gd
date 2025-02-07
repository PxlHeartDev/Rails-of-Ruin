class_name DialogueBox
extends MarginContainer

@export var text: Label
@export var portrait: TextureRect

@onready var options: GridContainer = $VBoxContainer/MarginContainer/Options

@onready var s_1: AudioStreamPlayer = $S1
@onready var s_2: AudioStreamPlayer = $S2
@onready var s_3: AudioStreamPlayer = $S3
@onready var s_4: AudioStreamPlayer = $S4

var audioPlayers: Array[AudioStreamPlayer]

var speaking: bool = false

var charCount

func _ready() -> void:
	audioPlayers = [
		s_1,
		s_2,
		s_3,
		s_4,
	]
	for o in options.get_children():
		o.queue_free()
	repopulate(preload("res://resources/dialogue/test/conv1/d1.tres"))

func repopulate(dialogueObject: Dialogue_Object) -> void:
	speaking = false
	text.text = dialogueObject.text
	for o in options.get_children():
		o.queue_free()
	for o in dialogueObject.options:
		var optionNode = preload("res://scenes/ui/fpv/dialogue/dialogue_option.tscn").instantiate()
		optionNode.text = o.text
		options.add_child(optionNode)
		optionNode.optionIcon.texture = o.icon
	for o in options.get_children():
		o.hide()
	startDialogue()

func startDialogue() -> void:
	text.visible_characters = 0
	charCount = TranslationServer.translate(text.text).length()
	
	speaking = true

func _process(delta: float) -> void:
	if speaking and text.visible_characters < charCount:
		text.visible_characters += 1
		audioPlayers.pick_random().play()
	if text.visible_characters >= charCount:
		for o in options.get_children():
			o.show()
