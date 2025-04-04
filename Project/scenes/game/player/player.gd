class_name Player
extends CharacterBody2D

signal damaged(amount: float)
signal died

enum State {
	IDLE,
	RUN,
	AIR,
	WALLSLIDE,
	WALLJUMP,
	DIE,
}

var state := State.IDLE:
	set(val):
		if val != state:
			Debug.trackVal("State", State.find_key(val))
		state = val
		updateAnimation()

@export_category("Nodes")
@export_group("Nodes")
@export var cam: Camera2D
@export var sprite: AnimatedSprite2D
@export var game: Node2D = get_parent()
@export var target: Node2D
@export var weapon: Weapon

@export_group("Timers")
@export var iFrames: Timer

@export_group("Areas")
@export var leftCheck: Area2D
@export var rightCheck: Area2D
@export var oneWayCheck: Area2D

@export_group("Components")
@export var healthComponent: Health_Component
@export var hitBoxComponent: HitBox_Component

var direction := Vector2.ZERO

var queueJump := false
var canJump := false:
	set(val):
		if val != canJump:
			Debug.trackVal("CanJump", val)
		canJump = val
var canWallJump := false:
	set(val):
		if val != canWallJump:
			Debug.trackVal("CanWallJump", canWallJump)
		canWallJump = val
var justJumped := false
var disableInput := false

func _ready() -> void:
	target.posChanged.connect(weapon.targetChanged)
	hitBoxComponent.hitRails.connect(hitRails)
	
	#var e = Color(0.604, 0.341, 0.706)

func _process(_delta: float) -> void:
	if state == State.DIE:
		return
	getInputs()
	if !isOnWall:
		if target.position.x < 0:
			flipSprite(true)
		else:
			flipSprite(false)

func _physics_process(delta: float) -> void:
	updateState()
	doJumpChecks()
	doMovementChecks()
	
	move_and_slide()
	
	if onRails:
		doRailsMovement(delta)
	
	Debug.trackVal("Position", "%s, %s" % [int(position.x), int(position.y)])

func nextLevel() -> void:
	state = State.IDLE

const SPEED: float = 300.0
const JUMP_STRENGTH: float = 750.0

# Allowed frames
const COYOTE_FRAMES: int = 4
# Tracker
var coyoteFrames: int = COYOTE_FRAMES:
	set(val):
		if val != coyoteFrames:
			Debug.trackVal("CoyoteFrames", val)
		coyoteFrames = val

func resetCoyote() -> void:
	if coyoteFrames != COYOTE_FRAMES:
		coyoteFrames = COYOTE_FRAMES

func getInputs() -> void:
	# Get movement direction
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	# Jump
	if Input.is_action_just_pressed("jump"):
		queueJump = true
	if Input.is_action_just_released("jump"):
		queueJump = false

func updateState() -> void:
	if state == State.DIE:
		return
	
	if floorCheck():
		justWallJumped = false
		if direction.x:
			state = State.RUN
		else:
			state = State.IDLE
	elif isOnWall:
		state = State.WALLSLIDE
	elif justWallJumped:
		state = State.WALLJUMP
	else:
		state = State.AIR

func updateAnimation() -> void:
	match state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")
		State.AIR:
			sprite.stop()
			sprite.animation = "jump"
			if velocity.y < -20:
				sprite.set_frame_and_progress(0, 0.0)
			elif velocity.y > 10:
				sprite.set_frame_and_progress(2, 0.0)
			else:
				sprite.set_frame_and_progress(1, 0.0)
		State.WALLSLIDE:
			sprite.stop()
			sprite.animation = "wall"
			if leftWall:
				flipSprite(false)
			elif rightWall:
				flipSprite(true)
		State.WALLJUMP:
			sprite.stop()
			sprite.animation = "jump"
		State.DIE:
			sprite.play("die")

func doMovementChecks() -> void:
	if state == State.DIE:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		return
	
	canJump = false
	canWallJump = false
	var xLim: float = 400
	
	match state:
		State.IDLE:
			canJump = true
			velocity.x = move_toward(velocity.x, 0, SPEED)
			resetCoyote()
		State.RUN:
			velocity.x += SPEED * direction.x
			canJump = true
			resetCoyote()
		State.AIR:
			if coyoteFrames > 0:
				coyoteFrames -= 1
				canJump = true
			velocity.x += SPEED/2 * direction.x
			velocity.y += get_gravity().y
			velocity.y = clamp(velocity.y, -1200, 1200)
		State.WALLSLIDE:
			if direction.y < -0.5:
				velocity.y += get_gravity().y/8 
			else:
				velocity.y += get_gravity().y/128
			if leftWall and direction.x > 0.5:
				velocity.x += SPEED * direction.x
			elif rightWall and direction.x < -0.5:
				velocity.x += SPEED * direction.x
			canWallJump = true
		State.WALLJUMP:
			xLim = 800
			velocity.x += SPEED/12 * direction.x
			velocity.x = move_toward(velocity.x, 0, SPEED/16)
			velocity.y += get_gravity().y
			velocity.y = clamp(velocity.y, -1200, 1200)
	
	if justJumped:
		justJumped = false
		coyoteFrames = 0
	velocity.x = clamp(velocity.x, -xLim, xLim)

func doJumpChecks() -> void:
	if queueJump and canJump:
		canJump = false
		queueJump = false
		justJumped = true
		velocity.y = -JUMP_STRENGTH * get_gravity().normalized().y
	if queueJump and canWallJump:
		canWallJump = false
		queueJump = false
		justWallJumped = true
		if leftWall:
			velocity.x = JUMP_STRENGTH * 200.0
		elif rightWall:
			velocity.x = -JUMP_STRENGTH * 200.0
		velocity.y = -JUMP_STRENGTH * get_gravity().normalized().y

func floorCheck() -> bool:
	if game.isGravityFlipped:
		return is_on_ceiling()
	else:
		return is_on_floor()

func flipSprite(flip: bool) -> void:
	sprite.flip_v = game.isGravityFlipped
	if game.isGravityFlipped:
		sprite.flip_h = !flip
	else:
		sprite.flip_h = flip

############
## Damage ##
############

func damage(attack: Attack_Obj) -> void:
	if attack.damage > 0:
		iFrames.start()
		hitBoxComponent.disable()
		
		damaged.emit(attack.damage)

func _on_i_frames_timeout() -> void:
	hitBoxComponent.enable()

func die() -> void:
	if state == State.DIE:
		return
	disableInput = true
	weapon.disabled = true
	state = State.DIE
	if healthComponent.health > 0:
		healthComponent.health = 0
	var camTween := create_tween()
	camTween.tween_property(cam, "zoom", Vector2(3.0, 3.0), 2.0).set_trans(Tween.TRANS_SINE)
	
	var speedTween := create_tween()
	speedTween.tween_property(Engine, "time_scale", 0.4, 1.5)
	
	target.set_deferred("process_mode", PROCESS_MODE_DISABLED)

var onRails: bool = false

func hitRails() -> void:
	onRails = true

func doRailsMovement(delta: float) -> void:
	position.x -= game.speed * delta

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "die":
		sprite.hide()
		weapon.hide()
		died.emit()

###############
## Wall Jump ##
###############

var isOnWall := false

var leftWall := false:
	set(val):
		if oneWayCheck.get_overlapping_bodies():
			leftWall = false
			anyWall(false)
			return
		leftWall = val
		anyWall(val)
var rightWall := false:
	set(val):
		if oneWayCheck.get_overlapping_bodies():
			rightWall = false
			anyWall(false)
			return
		rightWall = val
		anyWall(val)

var justWallJumped := false

func anyWall(val: bool) -> void:
	isOnWall = val
	if val:
		sprite.stop()
		sprite.animation = "wall"
		velocity.y = 0

func _on_left_wall_body_entered(_body: Node2D) -> void:
	if state == State.DIE:
		return
	leftWall = true
func _on_left_wall_body_exited(_body: Node2D) -> void:
	if state == State.DIE:
		return
	leftWall = false

func _on_right_wall_body_entered(_body: Node2D) -> void:
	if state == State.DIE:
		return
	rightWall = true
func _on_right_wall_body_exited(_body: Node2D) -> void:
	if state == State.DIE:
		return
	rightWall = false
