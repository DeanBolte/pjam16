extends CharacterBody2D

@export var max_health: float = 75
@export var current_health: float = max_health
@export var speed: int = 300
@export var invincibility_time: float = 1 # seconds of invincibility after being hit
@export var damage: float = 5
@export var self_knockback_multiplier: float = 50 # this enemy should be knocked back quite a bit

# We can remove a detection radius concept in favour of 'enemies must be in the same room'; this is
#	just easier to implement right now.
const SHOW_DETECTION_RADIUS: bool = false
const SHOW_MIN_DISTANCE: bool = false
const DETECTION_RADIUS = 500.0  # Maximum range where enemy detects the player
const MIN_DISTANCE = 150.0  # Distance where enemy starts running away

var is_invincible: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO # This STORES knockback force and gradually decreases over timer
var player: CharacterBody2D = null
var distance_to_player := 0
var can_shoot := true # Baloo must wait for shoot_cooldown_timer to finish before shooting again.

func _ready():
	# Not the best way to do this, but works for now
	player = get_tree().get_nodes_in_group("Players")[0]
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))
	$shoot_cooldown_timer.timeout.connect(Callable(self, "handle_finish_shoot_cooldown"))

func _process(delta: float) -> void:
	if player == null:
		return
	distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player < MIN_DISTANCE or distance_to_player > DETECTION_RADIUS:
		return
	_process_shoot_logic()

func _physics_process(delta: float) -> void:
	if player == null or distance_to_player > DETECTION_RADIUS:
		return

	look_at(player.global_position)

	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)  # Smooth decay
	else:
		calc_movement()
	move_and_slide()

# Note: This doesn't do that good of a job of making the enemy move smarter.
func calc_movement():
	var target_position = player.global_position
	
	if distance_to_player > MIN_DISTANCE:
		return # Don't do any movement if the player is outside the comfort zone 

	var flee_direction = (global_position - target_position).normalized()
	
	# Generate random offset to avoid just running in a straight line
	var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 100

	var new_target_position = global_position + (flee_direction * 150) + random_offset  # Move 150px away + random

	# Set target for pathfinding
	$NavigationAgent2D.target_position = new_target_position

	var next_path_position = $NavigationAgent2D.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * speed

	if $NavigationAgent2D.is_navigation_finished():
		return

	if $NavigationAgent2D.avoidance_enabled:
		$NavigationAgent2D.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _process_shoot_logic() -> void:
	$Crossbow.pull_back()
	if !can_shoot:
		return

	var direction = (player.global_position - global_position).normalized()
	$Crossbow.shoot(damage, direction)

	can_shoot = false
	$shoot_cooldown_timer.start()
	
func handle_finish_shoot_cooldown() -> void:
	can_shoot = true

func on_hit(damage: float) -> void:
	if is_invincible:
		return
	take_damage(damage)

func take_damage(damage: float) -> void:
	current_health -= damage
	print("Enemy took ", damage, " dmg")
	$hit_sound.play()
	DamageNumbers.display_number(floor(damage), global_position)
	
	var knockback_direction = (global_position - player.global_position).normalized()
	knockback_velocity = knockback_direction * damage * self_knockback_multiplier

	die() if current_health <= 0 else start_invincibility()

func die():
	queue_free()

func start_invincibility():
	is_invincible = true
	$invincibility_timer.start()
	modulate_sprites(Color(1, 1, 1, 0.5))

func end_invincibility():
	is_invincible = false
	modulate_sprites(Color(1, 1, 1, 1))

func modulate_sprites(color: Color):
	var sprites = find_children("", "Sprite2D")
	for sprite in sprites:
		sprite.modulate = color

func _draw():
	if (SHOW_DETECTION_RADIUS):
		draw_circle(Vector2.ZERO, DETECTION_RADIUS, Color(1, 0, 0, 0.5))
	if (SHOW_MIN_DISTANCE):
		draw_circle(Vector2.ZERO, MIN_DISTANCE, Color(0, 1, 0, 0.5))
