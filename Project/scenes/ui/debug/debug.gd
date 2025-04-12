extends CanvasLayer

@export var debugVals: VBoxContainer

@export var fps: Label
@export var coordinates: Label
@export var seedLabel: Label
@export var stateLabel: Label
@export var canJumpLabel: Label
@export var canWallJumpLabel: Label

var debugValList: Dictionary[String, Variant] = {}

var shown: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		debug()

func debug() -> void:
	shown = !shown
	visible = shown
	set_process.call_deferred(shown)

var times: Array[int]

func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_msec()

	# Remove frames older than 1 second in the `times` array
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front()

	times.append(now)
	fps.text = "FPS: %s" % str(times.size())

func trackVal(valName: String, val: Variant) -> void:
	if valName in debugValList.keys():
		debugValList[valName].text = "%s: %s" % [valName, val]
	else:
		var label = Label.new()
		label.text = "%s: %s" % [valName, val]
		debugVals.add_child(label)
		debugValList[valName] = label

func positionChanged(newPos: Vector2) -> void:
	coordinates.text = "Pos: %s, %s" % [int(newPos.x), int(newPos.y)]

func seedChanged(newSeed: int) -> void:
	seedLabel.text = "Seed: %s" % newSeed
