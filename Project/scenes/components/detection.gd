extends Area2D

signal detected

func _on_area_entered(area: Area2D) -> void:
	detected.emit()


func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
