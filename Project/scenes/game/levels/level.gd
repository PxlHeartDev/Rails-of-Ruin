extends Node2D

@onready var nav: NavigationRegion2D = $NavigationRegion2D

func _ready() -> void:
	await get_tree().process_frame
	nav.bake_navigation_polygon()
