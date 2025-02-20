extends MarginContainer

@onready var completeLabel: RichTextLabel = $CentrePopup/CompleteLabel
@onready var anim_complete: AnimationPlayer = $CentrePopup/AnimationPlayer

func _ready() -> void:
	anim_complete.play("show")

func _process(delta: float) -> void:
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if !is_node_ready():
			await ready
		completeLabel.text = "[center][wave amp=150 freq=10][rainbow freq=0.1 speed=1.0]" + tr("GAME_levelComplete")
