extends Node
class_name StateMachine

@export_group("Timers")
@export var navTimer: 		Timer

@export_group("")
@export var initState:		State
@export var enemy:			Enemy

var curState: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(onTransition)
	if initState:
		initState.enter(initState.name.to_lower())
		curState = initState
	
	await get_tree().create_timer(randf_range(0.01, 0.9)).timeout
	navTimer.start()

func _process(delta):
	if curState:
		curState.update(delta)

func _physics_process(delta):
	if curState:
		curState.physUpdate(delta)

func onTransition(state, newStateName):
	if state != curState:
		return
	
	var newState = states.get(newStateName.to_lower())
	
	if !newState:
		print("%s: State '%s' not found" % [enemy, newStateName])
		return
	
	if curState:
		curState.exit()
	newState.enter(curState.name)
	curState = newState

func die():
	onTransition(curState, "dying")

func _on_nav_timer_timeout():
	if curState.has_method("navUpdate"):
		curState.navUpdate()
