class_name Anomaly
extends Resource

var anomalyName: String
var function: Callable
var mapImage: String
var weight: float
var requireAnims: bool

func _init(
		_name: String = "",
		_func: Callable = Callable(),
		_img: String = "mystery",
		_weight: float = 1.0,
		_anims: bool = true,
) -> void:
	anomalyName = _name
	function = _func
	mapImage = _img
	weight = _weight
	requireAnims = _anims

func trigger() -> void:
	function.call()

func getImg() -> Texture2D:
	return load("res://assets/sprites/pathNodes/%s.png" % mapImage)
