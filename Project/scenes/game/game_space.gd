extends Node2D

@export_group("Nodes")
@export var audioManager: AudioManager
@export var anomalyManager: AnomalyManager
@export var enemies: Node2D
@export var player: Player

func _ready() -> void:
	anomalyManager.materiaManager.materiaBroken.connect(materiaBroken)
	anomalyManager.upgradePlayer.connect(changePlayerStat)

func enemySpawned(enemy: Enemy) -> void:
	enemy.died_sound.connect(enemyDied)

func enemyDied(pos: Vector2) -> void:
	audioManager.playSound(
			"res://assets/sfx/enemy/death/d%d.wav" % randi_range(1, 4),
			pos
	)

func materiaBroken(pos: Vector2) -> void:
	audioManager.playSound(
		"res://assets/sfx/enemy/death/d%d.wav" % randi_range(1, 4),
		pos
	)

func changePlayerStat(statName: String, val: Variant) -> void:
	player.stats.setStat(statName, val)

func getPlayerStat(statName: String) -> Variant:
	return player.stats.getStat(statName)
