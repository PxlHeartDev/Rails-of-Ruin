extends TileMapLayer

signal seedChanged(seed: int)

@export var useTerrain: bool = true
@export var airBlock: Vector2i
@export var solidBlock: Vector2i

@export var chunkWidth: int = 32
# Horizontal size goes left x chunks and right x chunks, meaning total world size is 2x
@export var worldSizeInChunks: int = 32
@export var worldBaseThickness: int = 256
@export var curSeed = 0:
	set(val):
		curSeed = val
		seedChanged.emit(val)


var CAVE_NOISE: FastNoiseLite = preload("res://assets/images/noise/cave.tres")
var RELIEF_NOISE: FastNoiseLite = preload("res://assets/images/noise/relief.tres")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_overlay"):
		curSeed += 1
		genWorld(curSeed)

func _ready() -> void:
	seedChanged.connect(Debug.seedChanged)
	curSeed = curSeed
	genWorld(curSeed)

func genWorld(seedToUse: int) -> void:
	CAVE_NOISE.seed = seedToUse
	RELIEF_NOISE.seed = seedToUse
	clear()
	for x in range(-worldSizeInChunks, worldSizeInChunks):
		genChunk(x)

func genChunk(cX: int) -> void:
	var airList: Array[Vector2i]
	for x in chunkWidth:
		var tX = cX * chunkWidth + x
		
		var relief = worldBaseThickness - floor(RELIEF_NOISE.get_noise_1d(tX/16.0) * 250.0)
		for y in relief:
			var tY = -y
			
			var noise = floor(abs((CAVE_NOISE.get_noise_2d(tX, tY)) * 20.0))
			
			if useTerrain:
				if noise == 0:
					airList.append(Vector2i(tX, tY))
				else:
					set_cell(Vector2i(tX, tY), 1, solidBlock)
			else:
				if noise == 0:
					set_cell(Vector2i(tX, tY), 1, airBlock)
				else:
					set_cell(Vector2i(tX, tY), 1, solidBlock)
	
	if useTerrain:
		set_cells_terrain_connect(airList, 0, 0)

func getReliefAt(x: int):
	return -(worldBaseThickness - floor(RELIEF_NOISE.get_noise_1d(x/16.0) * 250.0)) * 32
