class_name State_AirDying
extends State

@export var free: bool = true

func enter(prevState: String):
	pass

func physUpdate(_delta: float):
	enemy.velocity *= 0.98
