class_name Anomaly
extends Resource

var anomalyName: String
var function: Callable
var mapImage: String
var weight: float
var requireAnims: bool
var maxAppearances: int

var curAppearances: int = 0

func _init(
		_name: String = "",
		_func: Callable = Callable(),
		_img: String = "mystery",
		_weight: float = 1.0,
		_anims: bool = true,
		_maxApp: int = 999,
) -> void:
	anomalyName = _name
	function = _func
	mapImage = _img
	weight = _weight
	requireAnims = _anims
	maxAppearances = _maxApp

func trigger() -> void:
	function.call()
	Debug.trackVal("Last Anomaly", anomalyName)

func getImg() -> Texture2D:
	return load("res://assets/sprites/pathNodes/%s.png" % mapImage)
