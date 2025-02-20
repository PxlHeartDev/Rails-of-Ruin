class_name State_AirAttack
extends State

@export_group("Nodes")
@export var attackComponent: Attack_Component

@export_group("Timers")
@export var buildUp: Timer
@export var CD: Timer

var firstEntry := true
var prev: String

func enter(prevState: String):
	prev = prevState
	if firstEntry:
		CD.timeout.connect(cooldownDone)
		buildUp.timeout.connect(attack)
		firstEntry = false
	
	#attackComponent.disable()
	enemy.velocity *= 0.2
	buildUp.start()
	
	#var attackSFX = AudioStreamPlayer2D.new()
	#attackSFX.pitch_scale = 2.0
	#attackSFX.volume_db = -2.0
	#attackSFX.attenuation = 6.0
	#enemy.audioManager.playSound(attackSFX, enemy.position)

func exit():
	CD.stop()
	buildUp.stop()

var move := false

func cooldownDone():
	transitioned.emit(self, prev)

func physUpdate(_delta: float):
	if move:
		enemy.velocity *= 0.97
		enemy.move_and_slide()
		move = false
	else:
		move = true
	if (enemy.player.position-enemy.global_position).length_squared() >= 11000:
		transitioned.emit(self, "airtoplayer")

func attack() -> void:
	var attackPos: Vector2
	
	attackPos = enemy.player.position
	move = true
	
	var direction = attackPos - enemy.global_position
	
	enemy.velocity = direction.normalized() * 500.0
	if enemy.velocity.x < 0:
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false
	
	CD.start()
	attackComponent.enable()
	
	#var attackSFX = AudioStreamPlayer2D.new()
	#attackSFX.pitch_scale = 1.0
	#attackSFX.volume_db = -3.0
	#attackSFX.attenuation = 6.0
	#enemy.audioManager.playSound(attackSFX, enemy.position)
