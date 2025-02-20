class_name State_AirDying
extends State

func enter(prevState: String):
	var tween := create_tween()
	tween.tween_property(enemy, "modulate:a", 0.0, 0.5)
	tween.tween_callback(enemy.queue_free)

func physUpdate(_delta: float):
	enemy.velocity *= 0.98
