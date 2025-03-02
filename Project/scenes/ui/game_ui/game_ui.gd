class_name GameUI
extends CanvasLayer

signal anomalyCoveredScreen
signal anomalyProcessingComplete

@export_group("Nodes")
@export var completeLabel: RichTextLabel
@export var warningLabel: RichTextLabel

@export var healthBar: ProgressBar
@export var distanceIcon: TextureRect
@export var distanceLabel: Label
@export var anomaliesIcon: TextureRect
@export var anomaliesLabel: Label
@export var enemiesIcon: TextureRect
@export var enemiesLabel: Label

@export var fuelGauge: TextureProgressBar
@export var anomalyPass: TextureRect

@export_group("AnimationPlayers")
@export var anim_complete: AnimationPlayer
@export var anim_warning: AnimationPlayer

func _ready() -> void:
	anomalySurvived(0)
	enemyKilled(0)
	distanceUpdated(0)
	anim_warning.play("RESET")
	await get_tree().create_timer(1.0).timeout
	anomalyAlert()

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
	
	completeLabel.show()
	anim_complete.play("show")
	
	
	await anim_complete.animation_finished
	completeLabel.hide()

func anomalyAlert() -> void:
	anim_warning.play("alert")
	await anim_warning.animation_finished
	var tween := create_tween()
	tween.tween_method(setAnomalySweepProg, 0.0, 1.0, 1.0)
	tween.tween_callback(anomalyCoveredScreen.emit)
	await anomalyProcessingComplete
	var tween2 := create_tween()
	tween2.tween_method(setAnomalySweepProg, 1.0, 2.0, 1.0)



func setAnomalySweepProg(prog: float):
	anomalyPass.material.set_shader_parameter("sweepProg", prog)

func enemyKilled(newCount: int) -> void:
	enemiesIcon.tooltip_text = tr("GAME_enemiesKilled") % newCount
	enemiesLabel.text = str(newCount)

func speedUpdated(newSpeed: float) -> void:
	pass

func distanceUpdated(newDistance: float) -> void:
	distanceIcon.tooltip_text = tr("GAME_distance") % str(int(newDistance))
	distanceLabel.text = str(int(newDistance))

func fuelUpdated(newFuel: float) -> void:
	fuelGauge.value = newFuel

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if !is_node_ready():
			await ready
		completeLabel.text = "[center][wave amp=150 freq=10][rainbow freq=0.1 speed=1.0]" + tr("GAME_levelComplete")
		warningLabel.text = "[center][img]assets/sprites/ui/panel/icons/alert.png[/img][color=e75c57][pulse freq=2.0 color=#ffffff80][tornado radius=2 freq=4][shake] " + tr("GAME_anomalyIncoming") + " [img]assets/sprites/ui/panel/icons/alert.png[/img]"
