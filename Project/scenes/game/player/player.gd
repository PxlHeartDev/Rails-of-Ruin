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

var state := STATE.Idle

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = get_parent()
@onready var target: Node2D = $Target
@onready var weapon: Weapon = $Weapon

@onready var leftCheck: Area2D = $LeftWall
@onready var rightCheck: Area2D = $RightWall

@onready var healthComponent: Health_Component = $ComponentManager/Health_Component

var direction := Vector2.ZERO

var queueJump := false
var canJump := false
var canWallJump := false
var disableInput := false

func _ready() -> void:
	target.posChanged.connect(weapon.targetChanged)

func _process(_delta: float) -> void:
	updateAnimation()
	getInputs()

const SPEED: float = 300.0
const JUMP_STRENGTH: float = 750.0

# Allowed frames
const COYOTE_FRAMES: int = 4
# Tracker
var coyoteFrames: int = COYOTE_FRAMES

func _physics_process(_delta: float) -> void:
	updateState()
	doJumpChecks()
	doMovementChecks()
	
	# Apply velocity
	move_and_slide()
	
	Debug.positionChanged(position)

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
	Debug.playerStateChanged(STATE.find_key(state))

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
		STATE.Run:
			velocity.x += SPEED * direction.x
			canJump = true
		STATE.Air:
			if coyoteFrames > 0:
				coyoteFrames -= 1
			velocity.x += SPEED/2 * direction.x
			velocity.y += get_gravity().y
			velocity.y = clamp(velocity.y, -1200, 1200)
		STATE.WallSlide:
			if direction.y < -0.5:
				velocity.y += get_gravity().y/8 
			else:
				velocity.y += get_gravity().y/128
			canWallJump = true
		STATE.WallJump:
			xLim = 800
			velocity.x += SPEED/12 * direction.x
			velocity.x = move_toward(velocity.x, 0, SPEED/16)
			velocity.y += get_gravity().y
			velocity.y = clamp(velocity.y, -1200, 1200)
	
	velocity.x = clamp(velocity.x, -xLim, xLim)

func doJumpChecks() -> void:
	if queueJump and canJump:
		canJump = false
		queueJump = false
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
	if game.isGravityFlipped:
		sprite.flip_h = !flip
	else:
		sprite.flip_h = flip

func damage(attack: Attack_Obj) -> void:
	if attack.damage > 0:
		# TODO: Took damage, health bar and whatnot
		pass

func die() -> void:
	# TODO: Death sequence
	died.emit()

var isOnWall := false

var leftWall := false:
	set(val):
		leftWall = val
		anyWall(val)
var rightWall := false:
	set(val):
		rightWall = val
		anyWall(val)

var justWallJumped := false

func anyWall(val: bool) -> void:
	if floorCheck():
		return
	isOnWall = val
	if val:
		sprite.stop()
		sprite.animation = "wall"
		velocity.y = 0

func _on_left_wall_body_entered(body: Node2D) -> void:
	leftWall = true

func _on_left_wall_body_exited(body: Node2D) -> void:
	leftWall = false


func _on_right_wall_body_entered(body: Node2D) -> void:
	rightWall = true

func _on_right_wall_body_exited(body: Node2D) -> void:
	rightWall = false
