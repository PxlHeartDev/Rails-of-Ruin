extends Node2D

@onready var col: CollisionShape2D = $Area2D/CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer

signal playerExited

func _ready() -> void:
	col.set_deferred("disabled", true)

func levelCleared() -> void:
	col.set_deferred("disabled", false)
	anim.play("open")

func _on_area_2d_body_entered(body: Node2D) -> void:
	playerExited.emit()
