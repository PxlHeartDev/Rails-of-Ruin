class_name Room
extends Node2D

enum TYPE {
	None,
	Reactor,
}

var overlayOpacity: float = 0.439

@export_category("Room Transform")
@export var gridPos: Vector2i = Vector2i.ZERO
@export var roomSize: Vector2i = Vector2i.ONE

@export_category("Room Properties")
@export var roomType: TYPE = TYPE.None

func getOverlayColour() -> Color:
	var colour: Color
	match roomType:
		TYPE.None:
			colour = Color(0.408, 0.408, 0.408, overlayOpacity)
		TYPE.Reactor:
			colour = Color(0.876, 0.689, 0.503, overlayOpacity)
	return colour

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
