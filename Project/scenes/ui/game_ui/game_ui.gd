class_name GameUI
extends CanvasLayer

signal anomalyCoveredScreen
signal anomalyProcessingComplete
signal particlesComplete

signal completeLabelDone

signal againPressed
signal quitPressed

signal quitFadeComplete

@export_category("Nodes")
@export_group("Translate Nodes")
@export var completeLabel: RichTextLabel
@export var warningLabel: RichTextLabel
@export var gameOverLabel: RichTextLabel
@export var quipLabel: RichTextLabel

@export var againButton: Button
@export var quitButton: Button

@export_group("Main UI Nodes")
@export var main: MarginContainer
@export var bottomPanel: TextureRect
@export var anomalyPass: TextureRect
@export var gameOverPanel: ColorRect
@export var healthBar: ProgressBar


@export var distanceIcon: TextureRect
@export var distanceLabel: Label

@export var anomaliesIcon: TextureRect
@export var anomaliesLabel: Label

@export var enemiesIcon: TextureRect
@export var enemiesLabel: Label

@export var fuelGauge: TextureProgressBar


@export_group("Animation Players")
@export var anim_complete: AnimationPlayer
@export var anim_warning: AnimationPlayer
@export var anim_gameOver: AnimationPlayer

@export_group("Misc Nodes")
@export var deathParticles: CPUParticles2D

@export_group("Audio Nodes")
@export var bip: AudioStreamPlayer
@export var bip2: AudioStreamPlayer

func _ready() -> void:
	anomalySurvived(0)
	enemyKilled(0)
	distanceUpdated(0)
	anim_warning.play("RESET")
	
	for i in 100:
		if "quip" in tr("GAME_lose.quip%s" % i):
			quipCount = i - 1
			return

func levelChanged(level: Variant) -> void:
	pass
	#levelLabel.text = str(level)

func anomalySurvived(newCount: int) -> void:
	newCount -= 1
	anomaliesIcon.tooltip_text = tr("GAME_anomaliesSurvived") % newCount
	anomaliesLabel.text = str(newCount)
	
	if newCount <= 0:
		return
	
	anomaliesLabel.position.x =  10
	anomaliesLabel.scale = Vector2i(2, 2)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(anomaliesLabel, "position:x", 0, 0.2)
	tween.tween_property(anomaliesLabel, "scale:x", 1, 0.2)
	tween.tween_property(anomaliesLabel, "scale:y", 1, 0.2)
	
	completeLabel.show()
	anim_complete.play("show")
	
	
	await anim_complete.animation_finished
	completeLabelDone.emit()
	completeLabel.hide()

func anomalyAlert() -> void:
	anim_warning.play("alert")
	await anim_warning.animation_finished
	var tween := create_tween()
	tween.tween_method(setAnomalySweepProg, 0.0, 1.0, 1.0)
	if dead:
		return
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

###############
## Game Over ##
###############

var dead: bool = false

func died() -> void:
	dead = true
	anomalyPass.hide()

var quipCount = 0
func gameOver() -> void:
	Config.updateSetting("stats/deaths", int(Config.retrieveSetting("stats/deaths")) + 1)
	
	var chosenQuip: int = randi_range(0, quipCount)
	quipLabel.text = "[shake rate=3 level=2]"
	match chosenQuip:
		12:
			quipLabel.text += tr("GAME_lose.quip%s" % chosenQuip) % Config.retrieveSetting("stats/deaths")
		_:
			quipLabel.text += tr("GAME_lose.quip%s" % chosenQuip)
	
	toggleButtons(true)
	anim_gameOver.play("show")
	gameOverPanel.modulate.a = 1.0
	await get_tree().process_frame
	gameOverPanel.show()
	deathParticles.emitting = true

func _on_again_pressed() -> void:
	againPressed.emit()
	var tween: Tween = create_tween()
	tween.tween_property(gameOverPanel, "modulate:a", 0.0, 1.2)
	againButton.release_focus()
	toggleButtons(false)

func _on_quit_pressed() -> void:
	quitPressed.emit()
	var tween: Tween = create_tween()
	tween.tween_property(gameOverPanel, "modulate:a", 0.0, 1.2)
	
	main.hide()
	bottomPanel.hide()
	anomalyPass.hide()
	
	quitButton.release_focus()
	toggleButtons(false)
	
	await tween.finished
	quitFadeComplete.emit()

func toggleButtons(enabled: bool) -> void:
	againButton.disabled = !enabled
	quitButton.disabled = !enabled

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if !is_node_ready():
			await ready
		completeLabel.text = "[center][wave amp=150 freq=10][rainbow freq=0.1 speed=1.0]" + tr("GAME_levelComplete")
		warningLabel.text = "[center][img]assets/sprites/ui/panel/icons/alert.png[/img][color=e75c57][pulse freq=2.0 color=#ffffff80][tornado radius=2 freq=4][shake] " + tr("GAME_anomalyIncoming") + " [img]assets/sprites/ui/panel/icons/alert.png[/img]"
		gameOverLabel.text = "[wave freq=2 amp=100]" + tr("GAME_lose.generic")

func _on_death_particles_finished() -> void:
	particlesComplete.emit()

func _on_mouse_entered() -> void:
	bip.play()

func _on_pressed() -> void:
	bip2.play()
