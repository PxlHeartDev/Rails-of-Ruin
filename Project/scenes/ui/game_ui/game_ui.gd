extends CanvasLayer

@export_group("Nodes")
@export var completeLabel: RichTextLabel
@export var healthBar: ProgressBar

@export_group("AnimationPlayers")
@export var anim_complete: AnimationPlayer


func _process(delta: float) -> void:
	pass

func carriageComplete() -> void:
	completeLabel.show()
	anim_complete.play("show")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if !is_node_ready():
			await ready
		completeLabel.text = "[center][wave amp=150 freq=10][rainbow freq=0.1 speed=1.0]" + tr("GAME_levelComplete")
