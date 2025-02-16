class_name Player
extends CharacterBody2D

signal died

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = get_parent()
@onready var target: Node2D = $Target
@onready var weapon: Weapon = $Weapon

var direction: float = 0.0
const PUSH_FORCE: float = 10.0

var queueJump: bool = false
var canJump: bool = true
var disableInput: bool = false

func _ready() -> void:
	target.posChanged.connect(weapon.targetChanged)

func _process(_delta: float) -> void:
	# Get movement direction
	direction = Input.get_axis("move_left", "move_right")
	# Jump
	if Input.is_action_just_pressed("jump"):
		queueJump = true
	if Input.is_action_just_released("jump"):
		queueJump = false
	if target.position.x < 0:
		flipSprite(true)
	else:
		flipSprite(false)

const SPEED: float = 300.0
const JUMP_STRENGTH: float = 750.0

# Allowed frames
const COYOTE_FRAMES: int = 4
# Tracker
var coyoteFrames: int = COYOTE_FRAMES

func _physics_process(_delta: float) -> void:
	# Jump validity
	if floorCheck():
		sprite.play()
		canJump = true
		coyoteFrames = COYOTE_FRAMES
	elif coyoteFrames > 0:
		coyoteFrames -= 1
	else:
		canJump = false
		sprite.stop()
		sprite.animation = "jump"
		if velocity.y < -10:
			sprite.set_frame_and_progress(0, 0.0)
		elif velocity.y > 5:
			sprite.set_frame_and_progress(2, 0.0)
		else:
			sprite.set_frame_and_progress(1, 0.0)

	# Apply gravity
	if not floorCheck():
		velocity.y += get_gravity().y
		velocity.y = clamp(velocity.y, -1200, 1200)

	# Do jump
	if queueJump and canJump:
		canJump = false
		queueJump = false
		velocity.y = -JUMP_STRENGTH * get_gravity().normalized().y

	# Walking
	if floorCheck() and direction:
		sprite.play("run")
		velocity.x += SPEED * direction
	elif floorCheck() and !direction:
		sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif !floorCheck() and direction:
		velocity.x += SPEED/8 * direction
	elif !floorCheck() and !direction:
		velocity.x = move_toward(velocity.x, 0, SPEED/4)
	velocity.x = clamp(velocity.x, -400, 400)
	
	for i: int in get_slide_collision_count():
		var c: KinematicCollision2D = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)

	# Apply velocity
	move_and_slide()

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

func die() -> void:
	died.emit()
