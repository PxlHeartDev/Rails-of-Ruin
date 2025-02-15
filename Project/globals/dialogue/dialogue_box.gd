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

func optionSelected(option_object: Dialogue_Option) -> void:
	if option_object.next:
		repopulate(option_object.next)
	if !option_object.next and option_object.action != "end":
		print("Dialogue object for %s not set or invalid" % [option_object.text])
	callv(option_object.action, option_object.parameters)

func testFunction(p1: String) -> void:
	print(p1)

func end() -> void:
	hide()

func speak(character: String, conversation: String, sentence: String) -> void:
	repopulate(load("res://resources/dialogue/%s/%s/%s.tres" % [character, conversation, sentence]))

func repopulate(dialogueObject: Dialogue_Object) -> void:
	dialogueObject._ready()
	speaking = false
	text.text = dialogueObject.text
	portrait.texture = dialogueObject.portrait
	for o in options.get_children():
		o.queue_free()
	for o in dialogueObject.options:
		var optionNode = preload("res://globals/dialogue/dialogue_option.tscn").instantiate()
		optionNode.text = o.text
		optionNode.option_object = o
		optionNode.selected.connect(optionSelected)
		options.add_child(optionNode)
		optionNode.optionIcon.texture = o.icon
	for o in options.get_children():
		o.hide()
	show()
	startDialogue()

func startDialogue() -> void:
	text.visible_characters = 0
	charCount = TranslationServer.translate(text.text).length()
	
	speaking = true

func _process(delta: float) -> void:
	if speaking and text.visible_characters < charCount:
		text.visible_characters += 1
		audioPlayers.pick_random().play()
	if speaking and text.visible_characters >= charCount:
		for o in options.get_children():
			o.show()
