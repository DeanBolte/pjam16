extends CharacterBody2D

@export var speed: int = 10000
@export var health: int = 3
@export var invincibility_time: float = 2 # seconds of invincibility after being hit

# We can remove a detection radius concept in favour of 'enemies must be in the same room'; this is
#	just easier to implement right now.
@export var detection_radius: float = 400.0
const SHOW_DETECTION_RADIUS: bool = false

var is_invincible: bool = false

var player: CharacterBody2D = null

func _ready():
	# Not the best way to do this, but works for now
	player = get_tree().get_nodes_in_group("Players")[0]
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true

func _physics_process(delta: float) -> void:
	calc_path()
	pass

func calc_path():
	var target_position = player.global_position
	var distance = global_position.distance_to(target_position)
	if (distance > detection_radius):
		return

	$NavigationAgent2D.target_position = target_position

	var current_position = global_position
	var next_path_position = $NavigationAgent2D.get_next_path_position()
	var new_velocity = current_position.direction_to(next_path_position) * speed

	if ($NavigationAgent2D.is_navigation_finished()):
		return

	if ($NavigationAgent2D.avoidance_enabled):
		$NavigationAgent2D.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

	move_and_slide()

func on_hit():
	if is_invincible:
		return
	take_damage(1)

func take_damage(amount: int):
	health -= amount
	$hit_sound.play()
	print("Enemy took ", amount, " dmg")
	if health <= 0:
		die()
	else:
		start_invincibility()

func die():
	print("Enemy defeated!")
	queue_free()

func start_invincibility():
	if not is_invincible:
		is_invincible = true
		$invincibility_timer.start()
		$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))

		# We don't have to show vulnerability this way - we can do other ways. This shade of white is just obvious for now.
		# Slightly white shade to show invincibility
		$sprite.modulate = Color(1, 1, 1, 0.5)

func end_invincibility():
	is_invincible = false
	$sprite.modulate = Color(1, 1, 1, 1)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass
	
func _draw():
	if (!SHOW_DETECTION_RADIUS):
		return
	draw_circle(Vector2.ZERO, detection_radius, Color(1, 0, 0, 0.5))
