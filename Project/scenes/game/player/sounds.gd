extends Node2D

@export_group("Nodes")
@export var hurt: AudioStreamPlayer2D
@export var shoot: AudioStreamPlayer2D

func gotHit(damage: float) -> void:
	hurt.play()

func shot() -> void:
	shoot.play()
