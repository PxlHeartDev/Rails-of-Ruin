extends CanvasLayer

@export_group("Nodes")
@export var completeLabel: RichTextLabel
@export var healthBar: ProgressBar
@export var distanceIcon: TextureRect
@export var distanceLabel: Label
@export var anomaliesIcon: TextureRect
@export var anomaliesLabel: Label
@export var enemiesIcon: TextureRect
@export var enemiesLabel: Label

#@onready var levelLabel: Label = $Margin/Main/VBoxContainer3/TrainCarraige/Label

@export_group("AnimationPlayers")
@export var anim_complete: AnimationPlayer

func _ready() -> void:
	anomalySurvived(0)
	enemyKilled(0)
	distanceUpdated(0)

func carriageComplete() -> void:
	completeLabel.show()
	anim_complete.play("show")

func levelChanged(level: Variant) -> void:
	pass
	#levelLabel.text = str(level)

func anomalySurvived(newCount: int) -> void:
	anomaliesIcon.tooltip_text = tr("GAME_anomaliesSurvived") % newCount
	anomaliesLabel.text = str(newCount)
	anomaliesLabel.position.x =  10
	anomaliesLabel.scale = Vector2i(2, 2)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(anomaliesLabel, "position:x", 0, 0.2)
	tween.tween_property(anomaliesLabel, "scale:x", 1, 0.2)
	tween.tween_property(anomaliesLabel, "scale:y", 1, 0.2)

func enemyKilled(newCount: int) -> void:
	enemiesIcon.tooltip_text = tr("GAME_enemiesKilled") % newCount
	enemiesLabel.text = str(newCount)

func distanceUpdated(newDistance: int) -> void:
	distanceIcon.tooltip_text = tr("GAME_distance") % newDistance
	distanceLabel.text = str(newDistance)
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if !is_node_ready():
			await ready
		completeLabel.text = "[center][wave amp=150 freq=10][rainbow freq=0.1 speed=1.0]" + tr("GAME_levelComplete")
