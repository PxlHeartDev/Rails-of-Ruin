class_name AnomalyManager
extends Node2D

signal returnToPathSelection
signal spawnEnemy(enemy: Enemy)
signal healPlayer

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

func _ready() -> void:
	calcWeights()

func anomalySurvived(newCount: int) -> void:
	wave = newCount
	print(wave)

#############################
## Anomaly selection stuff ##
#############################

var validSpawnMin: Vector2 = Vector2(-800, -360)
var validSpawnMax: Vector2 = Vector2(320, -180)

# Ranges reasonably from 0 to 30, numbers quickly approach infinity at 80
var difficulty: int = 30

var anomalyList: Array[Anomaly] = [
	Anomaly.new("enemies_easy", summonEnemies.bind(1.5), "fight_e", 1.0),
	Anomaly.new("enemies_med", summonEnemies.bind(1.7), "fight_m", 0.5),
	Anomaly.new("enemies_hard", summonEnemies.bind(1.8), "fight_h", 0.2),
	Anomaly.new("heal", heal, "heal", 0.2, false),
	Anomaly.new("spawn_objects", spawnMateria, "mystery", 0.5),
]

const ENEMY_PATH = "res://scenes/game/enemies/enemies/"
var enemies: Array[Dictionary] = [
	{"n": "jawn", "w": 10.0},
	{"n": "dwain", "w": 10.0},
]

var totalEnemyWeight: float
var totalAnomalyWeight: float

func calcWeights() -> void:
	totalEnemyWeight = 0
	for i in enemies:
		totalEnemyWeight += i.w
	
	totalAnomalyWeight = 0
	for i in anomalyList:
		totalAnomalyWeight += i.weight

func chooseAnomaly() -> Anomaly:
	var chosen: float = randf_range(0, totalAnomalyWeight)
	var curWeight: float = 0
	for i in anomalyList:
		if chosen < i.weight + curWeight:
			return i
		curWeight += i.weight
	return null

func chooseEnemy() -> Enemy:
	var chosen: float = randf_range(0, totalEnemyWeight)
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
			+ (difficulty-30)/(80-difficulty))
	for i in enemyCount:
		await get_tree().physics_frame
		spawnEnemy.emit(chooseEnemy())

func spawnMateria() -> void:
	for i in int(wave ** 0.5):
		materiaManager.attemptSpawn(Region.PLAINS)
	await get_tree().create_timer(1.0).timeout
	returnToPathSelection.emit()

func heal() -> void:
	await get_tree().create_timer(1.0).timeout
	healPlayer.emit()
	await get_tree().create_timer(1.0).timeout
	returnToPathSelection.emit()

func _on_timer_timeout() -> void:
	pass
