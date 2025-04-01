extends Node2D

@export_group("Nodes")
@export var audioManager: AudioManager

func _ready() -> void:
	pass

func enemySpawned(enemy: Enemy) -> void:
	enemy.died_sound.connect(enemyDied)

func enemyDied(pos: Vector2) -> void:
	audioManager.playSound(
			"res://assets/sfx/enemy/death/d%d.wav" % randi_range(1, 4),
			pos
	)
