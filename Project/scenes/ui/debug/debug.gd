extends CanvasLayer

@export var fps: Label
@export var coordinates: Label
@export var seedLabel: Label
@export var stateLabel: Label

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

func positionChanged(newPos: Vector2) -> void:
	coordinates.text = "Pos: %s, %s" % [int(newPos.x), int(newPos.y)]

func seedChanged(newSeed: int) -> void:
	seedLabel.text = "Seed: %s" % newSeed

func playerStateChanged(newState: String) -> void:
	stateLabel.text = "State: %s" % newState
