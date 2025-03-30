class_name MateriaManager
extends Node2D

var existingMateria: Dictionary[String, circle]
@export var anomalyManager: AnomalyManager

const MATERIA_PATH = "res://scenes/game/materia/"
const materias: Dictionary[String, Array] = {
	"plains": [
		"2x2",
		"tet_s",
	],
	"dessert": [
		"2x2",
	],
	"tundra": [
		"2x2",
	],
	"ocean": [
		"2x2",
	],
	"anomaly": [
		"2x2",
	],
}

func attemptSpawn(region: AnomalyManager.Region) -> Materia:
	var regionName = AnomalyManager.Region.keys()[region].to_lower()
	var materiaName = materias[regionName].pick_random()
	var materia = load("%s%s/%s.tscn" % [MATERIA_PATH, regionName, materiaName]).instantiate() as Materia
	
	var exitFlag: int = 0
	var materiaBounds = circle.new(materia.position, materia.boundingCircleRadius)
	materia.minPos = anomalyManager.validSpawnMin
	materia.maxPos = anomalyManager.validSpawnMax
	materia.randomizePos()
	materiaBounds.pos = materia.initPos
	
	while !isValidSpawn(materiaBounds):
		materia.randomizePos()
		materiaBounds.pos = materia.initPos
		exitFlag += 1
		if exitFlag >= 5:
			materia.queue_free()
			return null
	
	materia.setParticleRegion(region)
	existingMateria.get_or_add(str(materia), materiaBounds)
	
	add_child(materia)
	return materia

func removeMateria(materia: Materia) -> void:
	existingMateria.erase(str(materia))

func isValidSpawn(new: circle) -> bool:
	for m in existingMateria.values():
		if m.isOverlapping(new):
			return false
	return true

class circle:
	var pos: Vector2i = Vector2i.ZERO
	var rad: float = 1.0
	
	func _init(_pos: Vector2i, _rad: float) -> void:
		pos = _pos
		rad = _rad
	
	func isOverlapping(other: circle) -> bool:
		return (rad + other.rad) ** 2 > pos.distance_squared_to(other.pos)
