class_name AnomalyManager
extends Node2D

signal spawnEnemy(enemy: Enemy)

# Ranges reasonably from 0 to 30, numbers quickly approach infinity at 80
var difficulty: int = 30

var wave: int = 50

var anomalyList: Dictionary[String, Callable] = {
	"enemies_easy": summonEnemies.bind(1.5),
	"enemies_mid": summonEnemies.bind(1.7),
	"enemies_hard": summonEnemies.bind(1.8),
}

const ENEMY_PATH = "res://scenes/game/enemies/enemies/"
var enemies: Array[Dictionary] = [
	{"n": "jawn", "w": 10.0},
	{"n": "dwain", "w": 10.0},
]

var totalWeight: float

func chooseAnomaly() -> Callable:
	return anomalyList[anomalyList.keys().pick_random()]

func chooseEnemy() -> Enemy:
	if !totalWeight:
		for i in enemies:
			totalWeight += i.w
	
	var chosen: float = randf_range(0, totalWeight)
	var curWeight: float = 0
	for i in enemies:
		if chosen < i.w + curWeight:
			return load("%s%s.tscn" % [ENEMY_PATH, i.n]).instantiate()
		curWeight += i.w
	return null

# https://www.desmos.com/calculator/pvgtj4w5wf
func summonEnemies(diff: float) -> void:
	var enemyCount: int = int(
			randf_range(5.0, 10.0
			) * (
			(wave/(80-difficulty)) + diff - 0.5 ) ** diff
			+ difficulty / 5.0)
	for i in enemyCount:
		await get_tree().physics_frame
		spawnEnemy.emit(chooseEnemy())
