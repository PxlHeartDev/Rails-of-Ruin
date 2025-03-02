class_name Player
extends CharacterBody2D

signal died

enum STATE {
	Idle,
	Run,
	Air,
	WallSlide,
	WallJump,
}

var state := STATE.Idle:
	set(val):
		if val != state:
			Debug.trackVal("State", STATE.find_key(val))
		state = val

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = get_parent()
@onready var target: Node2D = $Camera2D/Target
@onready var weapon: Weapon = $Weapon
@onready var iFrames: Timer = $iFrames


@onready var leftCheck: Area2D = $LeftWall
@onready var rightCheck: Area2D = $RightWall

@onready var healthComponent: Health_Component = $ComponentManager/Health_Component
@onready var hitBoxComponent: HitBox_Component = $ComponentManager/HitBox_Component

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

func _process(_delta: float) -> void:
	updateAnimation()
	getInputs()

func nextLevel() -> void:
	state = STATE.Idle

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

func _physics_process(_delta: float) -> void:
	updateState()
	doJumpChecks()
	doMovementChecks()
	
	move_and_slide()
	
	Debug.trackVal("Position", "%s, %s" % [int(position.x), int(position.y)])

func getInputs() -> void:
	# Get movement direction
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	# Jump
	if Input.is_action_just_pressed("jump"):
		queueJump = true
	if Input.is_action_just_released("jump"):
		queueJump = false

func updateState() -> void:
	if floorCheck():
		justWallJumped = false
		if direction.x:
			state = STATE.Run
		else:
			state = STATE.Idle
	elif isOnWall:
		state = STATE.WallSlide
	elif justWallJumped:
		state = STATE.WallJump
	else:
		state = STATE.Air

func updateAnimation() -> void:
	if target.position.x < 0:
		flipSprite(true)
	else:
		flipSprite(false)
	match state:
		STATE.Idle:
			sprite.play("idle")
		STATE.Run:
			sprite.play("run")
		STATE.Air:
			sprite.stop()
			sprite.animation = "jump"
			if velocity.y < -20:
				sprite.set_frame_and_progress(0, 0.0)
			elif velocity.y > 10:
				sprite.set_frame_and_progress(2, 0.0)
			else:
				sprite.set_frame_and_progress(1, 0.0)
		STATE.WallSlide:
			sprite.stop()
			sprite.animation = "wall"
			if leftWall:
				flipSprite(false)
			elif rightWall:
				flipSprite(true)
		STATE.WallJump:
			sprite.stop()
			sprite.animation = "jump"

func doMovementChecks() -> void:
	canJump = false
	canWallJump = false
	var xLim: float = 400
	match state:
		STATE.Idle:
			canJump = true
			velocity.x = move_toward(velocity.x, 0, SPEED)
			resetCoyote()
		STATE.Run:
			velocity.x += SPEED * direction.x
			canJump = true
			resetCoyote()
		STATE.Air:
			if coyoteFrames > 0:
				coyoteFrames -= 1
				canJump = true
			velocity.x += SPEED/2 * direction.x
			velocity.y += get_gravity().y
			velocity.y = clamp(velocity.y, -1200, 1200)
		STATE.WallSlide:
			if direction.y < -0.5:
				velocity.y += get_gravity().y/8 
			else:
				velocity.y += get_gravity().y/128
			if leftWall and direction.x > 0.5:
				velocity.x += SPEED * direction.x
			elif rightWall and direction.x < -0.5:
				velocity.x += SPEED * direction.x
			canWallJump = true
		STATE.WallJump:
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
		# TODO: Take damage anim
		pass

func _on_i_frames_timeout() -> void:
	hitBoxComponent.enable()

func die() -> void:
	# TODO: Death sequence
	died.emit()
	if healthComponent.health > 0:
		healthComponent.health = 0

###############
## Wall Jump ##
###############

var isOnWall := false

@onready var oneWayCheck: Area2D = $OneWayCheck

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
	leftWall = true
func _on_left_wall_body_exited(_body: Node2D) -> void:
	leftWall = false

func _on_right_wall_body_entered(_body: Node2D) -> void:
	rightWall = true
func _on_right_wall_body_exited(_body: Node2D) -> void:
	rightWall = false
