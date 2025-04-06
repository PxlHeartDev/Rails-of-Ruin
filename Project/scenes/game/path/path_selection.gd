class_name PathSelection
extends CanvasLayer

@export_group("Nodes")
@export var stuff: Node2D
@export var clickEffect: Sprite2D
@export var nodes: Node2D
@export var startNode: PathNode
@export var light: PointLight2D
@export var fade: ColorRect
@export var audio: AudioStreamPlayer

@export_group("Animation Players")
@export var anim_click: AnimationPlayer
@export var anim_show: AnimationPlayer

# Layer: PathNode list
var pathNodes: Dictionary[int, Array] = {}

var pathNode: PackedScene = preload("res://scenes/game/path/path_node.tscn")

var currentNodeLayer: int = 1
var lastSelectedNode: PathNode

func _ready() -> void:
	startNode.clickedVis()
	reset()
	showStuff()

func showStuff() -> void:
	anim_show.play("hide")
	await anim_show.animation_finished
	var p = pathNodes.keys()
	p.reverse()
	for i in p:
		for j in pathNodes[i]:
			if i > currentNodeLayer:
				j.toggle(false)
			elif i == currentNodeLayer:
				j.toggle(true)
			else:
				if j.crack.visible:
					j.clickedVis()
				else:
					j.toggle(false, true)
			if j == lastSelectedNode:
				for k in j.lines.get_children():
					k.default_color = Color.WHITE
	nodes.position.x = -clamp(currentNodeLayer - 5, 0, 1000) * 90
	stuff.show()
	anim_show.play("show")

func reset() -> void:
	currentNodeLayer = 1
	for i in pathNodes.keys():
		if i == 0:
			continue
		for j in pathNodes[i]:
			j.queue_free()
		pathNodes[i] = []
	startNode.connections = {}
	pathNodes.get_or_add(0, [startNode])
	lastSelectedNode = startNode
	generatePathNodes()
	for i in pathNodes.values():
		for j in i:
			j.updateConnections()

func generatePathNodes() -> void:
	for i in 20:
		generateNextLayer(i)
	for i in pathNodes.keys():
		yOffsetNodesInLayer(i)

func generateNextLayer(curLayer: int) -> Array[PathNode]:
	var choice: int
	var newNode: PathNode
	var layerSize: int = 1
	
	match curLayer:
		0:
			layerSize = 2
		19:
			layerSize = 1
		_:
			if curLayer in range(0, 18):
				layerSize = randi_range(1, 4)
	
	var newNodes: Array[PathNode]
	
	for i in layerSize:
		newNode = createNode(curLayer + 1)
		newNodes.append(newNode)
	
	for i in pathNodes[curLayer]:
		for j in newNodes:
			i.connectTo(j)
	
	return []
	

func createNode(nodeLayer: int) -> PathNode:
	var newNode
	newNode = pathNode.instantiate()
	newNode.nodeLayer = nodeLayer
	newNode.position.x = 64 + (nodeLayer) * 90 + randf_range(-15, 15)
	newNode.clicked.connect(nodeClicked)
	newNode.hovered.connect(nodeHovered)
	newNode.unhovered.connect(nodeUnhovered)
	pathNodes.get_or_add(nodeLayer, []).append(newNode)
	nodes.add_child(newNode)
	
	return newNode

func getRandomNodeInLayer(nodeLayer: int) -> PathNode:
	return pathNodes[nodeLayer].pick_random()

func yOffsetNodesInLayer(nodeLayer:  int) -> Array[PathNode]:
	var layerNodes = pathNodes.get_or_add(nodeLayer, [])
	if !layerNodes:
		return []
	var nodeCount = len(layerNodes)
	for i in range(0, nodeCount):
		layerNodes[i].position.y = 270 + (int(nodeCount/2) - i*2.0) * 48 + randf_range(-10, 10)
	
	return []

func nodeHovered(node: PathNode) -> void:
	light.position = node.global_position
	tweenLight(10.0)
	lastSelectedNode.connections[node].default_color = Color(0.912, 0.683, 0.894)

func nodeUnhovered(node: PathNode) -> void:
	tweenLight(0.0)
	if stuff.visible:
		lastSelectedNode.connections[node].default_color = Color.WHITE

func nodeClicked(node: PathNode) -> void:
	tweenLight(0.0)
	currentNodeLayer += 1
	for i in pathNodes.keys():
		if i < currentNodeLayer:
			continue
		for j in pathNodes[i]:
			j.toggle(false, true if j in pathNodes[node.nodeLayer] else false if j != node else true)
	lastSelectedNode.clickedVis()
	audio.play()
	clickEffect.position = node.global_position
	anim_click.play("click")
	anim_show.play("hide")
	await anim_show.animation_finished
	lastSelectedNode = node
	stuff.hide()
	anim_show.play("show")
	await get_tree().create_timer(1.0).timeout
	showStuff()

var lightTween: Tween
func tweenLight(val: float) -> void:
	if lightTween and lightTween.is_running():
		lightTween.stop()
	lightTween = create_tween()
	lightTween.tween_property(light, "energy", val, 0.2)
