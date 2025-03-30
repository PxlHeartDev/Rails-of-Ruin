@tool
class_name Materia
extends Node2D

enum ROTATIONMODES {
	sin,
	continuous,
	linear,
}

@export_group("Materia Parameters")
@export var boundingCircleRadius: float = 1.0

@export var minPos: Vector2i = Vector2i.ZERO
@export var maxPos: Vector2i = Vector2i.ONE

# 0.0 = 100% 1 / 1.0 = 100% 2
@export var particleRatio: float = 0.0

@export_category("Movement Parameters")
@export var randomRest: bool = true
@export_group("Rotation")
@export var initRot: float = 0
@export var rotRange: float = 10.0
@export var rotSpeed: float = 1.0
@export var rotMode: ROTATIONMODES = ROTATIONMODES.sin

@export_group("Position")
@export var randomPos: bool = false
@export var initPos: Vector2i = Vector2i(0, 0)
@export var hoverRange: Vector2 = Vector2(2.0, 2.0)
@export var hoverSpeed: float = 1.0

@export_category("Nodes")
@export var blocksTileMap: TileMapLayer
@export var healthComponent: Health_Component
@export var breakParticles: CPUParticles2D
@export var breakParticles2: CPUParticles2D

var timeRand: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	timeRand = randf_range(-20.0, 20.0)
	
	if randomPos:
		randomizePos()
	
	if randomRest:
		randomizeRot()
		randomizeRotSpeed()
		randomizeHover()
		randomizeHoverSpeed()
	
	breakParticles.amount = int(boundingCircleRadius * (1.0 - particleRatio))
	breakParticles2.amount = int(boundingCircleRadius * particleRatio)
	breakParticles.emission_sphere_radius = boundingCircleRadius * 0.8

var rotFlag: bool = false

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	position.x = (initPos.x + 
			sin(hoverSpeed * 
			((Time.get_ticks_msec()/1000.0) + timeRand)) * 
			hoverRange.x)
	position.y = (initPos.y + 
			cos(hoverSpeed * 
			((Time.get_ticks_msec()/1000.0) - timeRand)) * 
			hoverRange.y)
	
	match rotMode:
		ROTATIONMODES.sin:
			rotation = (initRot + 
					sin(rotSpeed * 
					(Time.get_ticks_msec() + timeRand)/1000.0) * 
					deg_to_rad(rotRange))
		ROTATIONMODES.continuous:
			rotation += deg_to_rad(rotSpeed)
		ROTATIONMODES.linear:
			if rotFlag:
				rotation += deg_to_rad(rotSpeed)
				if rotation - initRot >= deg_to_rad(rotRange):
					rotFlag = false
			elif rotation - initRot >= -deg_to_rad(rotRange):
				rotation -= deg_to_rad(rotSpeed)
			else:
				rotFlag = true

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, boundingCircleRadius, Color(0.584, 0.871, 0.875, 0.396))

func setParticleRegion(region: AnomalyManager.Region) -> void:
	match region:
		AnomalyManager.Region.PLAINS:
			particleRatio = 0.2
			breakParticles2.color = Color("56b415")
		AnomalyManager.Region.DESSERT:
			pass
		AnomalyManager.Region.TUNDRA:
			pass
		AnomalyManager.Region.OCEAN:
			pass
		AnomalyManager.Region.ANOMALY:
			pass

func randomizeRot(minR: float = -PI, maxR: float = PI) -> void:
	initRot = randf_range(minR, maxR) + initRot
	rotation = initRot

func randomizeRotSpeed(minS: float = 0, maxS: float = 1.0) -> void:
	rotSpeed = randf_range(minS, maxS)

func randomizePos(minP: Vector2i = minPos, maxP: Vector2i = maxPos) -> void:
	initPos.x = randi_range(minP.x, maxP.x)
	initPos.y = randi_range(minP.y, maxP.y)
	position = initPos

func randomizeHover(minH: float = 0.0, maxH: float = 2.0) -> void:
	hoverRange.x = randf_range(minH, maxH)
	hoverRange.y = randf_range(minH, maxH)

func randomizeHoverSpeed(minS: float = 0.0, maxS: float = 1.0) -> void:
	hoverSpeed = randf_range(minS, maxS)

func damage(attack: Attack_Obj) -> void:
	healthComponent.damage(attack.damage)

func die() -> void:
	breakParticles.emitting = true
	breakParticles2.emitting = true
	blocksTileMap.hide()
	blocksTileMap.collision_enabled = false
	await breakParticles.finished
	queue_free()
