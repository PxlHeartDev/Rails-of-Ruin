extends TileMapLayer

@export var useTerrain: bool = true
@export var airBlock: Vector2i
@export var solidBlock: Vector2i

@export var chunkWidth: int = 32
# Horizontal size goes left x chunks and right x chunks, meaning total world size is 2x
@export var worldSizeInChunks: int = 32
@export var worldBaseThickness: int = 256

const CAVE_NOISE: FastNoiseLite = preload("res://assets/images/noise/cave.tres")
const RELIEF_NOISE: FastNoiseLite = preload("res://assets/images/noise/relief.tres")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advanceDialogue"):
		clear()
		for x in range(-worldSizeInChunks, worldSizeInChunks):
			genChunk(x)

func _ready() -> void:
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
					set_cell(Vector2i(tX, tY), 1, Vector2i(3, 5))
			else:
				if noise == 0:
					set_cell(Vector2i(tX, tY), 1, airBlock)
				else:
					set_cell(Vector2i(tX, tY), 1, solidBlock)
	
	if useTerrain:
		set_cells_terrain_connect(airList, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
