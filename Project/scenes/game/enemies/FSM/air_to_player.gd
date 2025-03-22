class_name State_AirToPlayer
extends State

func enter(prevState: String):
	if !enemy.is_node_ready():
		await enemy.ready
	navUpdate()

func exit():
	pass

func update(_delta: float):
	if !enemy:
		return
	var playerPos = enemy.player.position
	var direction = playerPos - enemy.position
	
	enemy.sprite.flip_h = direction.x < 0
	
	if direction.length_squared() < 10000:
		transitioned.emit(self, "airattack")

func physUpdate(_delta: float):
	if enemy.nav.is_navigation_finished():
		return
	
	var curPos: Vector2 = enemy.global_position
	var nextPos: Vector2 = enemy.nav.get_next_path_position()
	
	enemy.velocity = curPos.direction_to(nextPos) * enemy.speed
	
	enemy.move_and_slide()

func navUpdate():
	if enemy.player == null:
		await get_tree().process_frame
	var playerPos = enemy.player.position
	enemy.nav.target_position = playerPos
