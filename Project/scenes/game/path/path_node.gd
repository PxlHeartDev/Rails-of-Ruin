class_name PathNode
extends Node2D

signal hovered(node: PathNode)
signal unhovered(node: PathNode)
signal clicked(node: PathNode)

@export_group("Nodes")
@export var button: Button
@export var sprite: Sprite2D
@export var lines: Node2D
@export var crack: Sprite2D

const PINK = Color(0.912, 0.683, 0.894) #e9aee4
const GREY = Color(0.8, 0.8, 0.8) # cccccc
const DIMMED = Color(0.342, 0.342, 0.342) #575757

var nodeLayer: int = 0

var disabled: bool = false
var dimmed: bool = false
var selected: bool = false

var connections: Dictionary[PathNode, Line2D]

func connectTo(node: PathNode) -> void:
	connections.merge({node: drawLine(null, node.position)})

func updateConnections() -> void:
	for i in connections.keys():
		drawLine(connections[i], i.position)

func updateLineColours() -> void:
	if disabled:
		for i in lines.get_children():
			i.default_color = GREY
	elif selected:
		for i in lines.get_children():
			i.default_color = Color.WHITE
	for i in connections.keys():
		if i.dimmed or dimmed:
			connections[i].default_color = DIMMED
		elif i.disabled:
			connections[i].default_color = GREY
		else:
			connections[i].default_color = Color.WHITE

func drawLine(line: Line2D, pos: Vector2) -> Line2D:
	if line:
		line.set_point_position(1, pos - position)
		return line
	else:
		var newLine = Line2D.new()
		newLine.width = 2
		newLine.add_point(Vector2(0, 0))
		newLine.add_point(pos - position, 1)
		lines.add_child(newLine)
		return newLine

func toggle(enabled: bool = false, dim: bool = false) -> void:
	button.disabled = !enabled
	disabled = !enabled
	dimmed = dim
	updateLineColours()
	if selected:
		return
	if disabled and !dim:
		sprite.modulate = GREY
	elif dim:
		sprite.modulate = DIMMED
	else:
		sprite.modulate = Color.WHITE

func _hovered() -> void:
	if disabled:
		return
	sprite.modulate = PINK
	hovered.emit(self)
	for i in lines.get_children():
		i.default_color = PINK

func _unhovered() -> void:
	if disabled or button.has_focus():
		return
	sprite.modulate = Color.WHITE
	unhovered.emit(self)
	for i in lines.get_children():
		i.default_color = GREY

func _clicked() -> void:
	if disabled:
		return
	disabled = true
	selected = true
	clickedVis()
	clicked.emit(self)

func clickedVis() -> void:
	toggle(false, false)
	for i in connections.keys():
		if i.selected:
			connections[i].default_color = PINK
	crack.show()
	sprite.modulate = PINK
