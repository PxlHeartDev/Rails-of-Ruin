class_name Level
extends Node2D

signal spawnEnemy(enemy: Enemy)

@onready var nav: NavigationRegion2D = $NavigationRegion2D

@export_group("Nodes")
@export var entrance: Node2D
@export var exit: Node2D

@export_group("Level Details")
@export var enemyCount: int = 1

var spawnpoints: Array[Node]

func _ready() -> void:
	await get_tree().process_frame
	nav.bake_navigation_polygon()
	spawnpoints = get_tree().get_nodes_in_group("enemy_spawn")
	if !spawnpoints:
		print("Level has no valid spawns")
	spawnEnemies()

func spawnEnemies() -> void:
	for i in enemyCount:
		var spawn = spawnpoints.pick_random()
		var enemy = load("res://scenes/game/enemies/jawn.tscn").instantiate()
		enemy.position = spawn.position
		spawnEnemy.emit(enemy)
