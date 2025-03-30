class_name AnomalyManager
extends Node2D

signal spawnEnemy(enemy: Enemy)

enum Region {
	PLAINS,
	DESSERT,
	TUNDRA,
	OCEAN,
	ANOMALY,
}

@export var materiaManager: MateriaManager
@export var timer: Timer

var wave: int = 1

func anomalySurvived(newCount: int) -> void:
	wave = newCount

#############################
## Anomaly selection stuff ##
#############################

var validSpawnMin: Vector2 = Vector2(-800, -360)
var validSpawnMax: Vector2 = Vector2(320, -180)

# Ranges reasonably from 0 to 30, numbers quickly approach infinity at 80
var difficulty: int = 30


var enemySpawnList: Array[String] = [
	"enemies_easy",
	"enemies_mid",
	"enemies_hard",
]

var anomalyList: Dictionary[String, Callable] = {
	"enemies_easy": summonEnemies.bind(1.5),
	"enemies_mid": summonEnemies.bind(1.7),
	"enemies_hard": summonEnemies.bind(1.8),
	"spawn_objects": spawnMateria,
}

const ENEMY_PATH = "res://scenes/game/enemies/enemies/"
var enemies: Array[Dictionary] = [
	{"n": "jawn", "w": 10.0},
	{"n": "dwain", "w": 10.0},
]

var totalWeight: float

func spawnEnemies() -> Callable:
	return anomalyList[enemySpawnList.pick_random()]

func chooseAnomaly() -> Callable:
	var chosen: String
	while !chosen or "enemies" in chosen:
		chosen = anomalyList.keys().pick_random()
	return anomalyList[chosen]

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
			(wave/(80.0-difficulty)) + diff - 0.5 ) ** diff
			+ difficulty / 5.0)
	for i in enemyCount:
		await get_tree().physics_frame
		spawnEnemy.emit(chooseEnemy())

func spawnMateria() -> void:
	for i in int(wave ** 0.5):
		materiaManager.attemptSpawn(Region.PLAINS)


func _on_timer_timeout() -> void:
	pass
