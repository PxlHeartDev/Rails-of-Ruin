class_name State_AirDying
extends State

signal faded

@export var free: bool = true

func enter(prevState: String):
	var tween := create_tween().set_parallel(true)
	tween.tween_property(enemy.sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(enemy.sprite, "scale:x", 0.0, 0.5)
	tween.tween_property(enemy.sprite, "scale:y", 0.0, 0.5)
	tween.chain()
	tween.tween_callback(faded.emit)
	if free:
		tween.chain()
		tween.tween_callback(enemy.queue_free)

func physUpdate(_delta: float):
	enemy.velocity *= 0.98
