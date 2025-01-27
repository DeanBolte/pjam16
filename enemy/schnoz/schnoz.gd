extends CharacterBody2D

@onready var sfx_manager = get_node("../../../../SfxManager")
@onready var death_sfx = preload("res://audio/sfx/enemy_death.wav")

@export var max_health: float = 100
@export var current_health: float = max_health
@export var speed: int = 10000
@export var invincibility_time: float = 1 # seconds of invincibility after being hit
@export var damage: float = 5
@export var self_knockback_multiplier: float = 50 # this enemy should be knocked back quite a bit

# We can remove a detection radius concept in favour of 'enemies must be in the same room'; this is
#	just easier to implement right now.
@export var detection_radius: float = 400.0
const SHOW_DETECTION_RADIUS: bool = false

var is_invincible: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO # This STORES knockback force and gradually decreases over timer
var player: CharacterBody2D = null

signal enemy_dead(enemy: CharacterBody2D)

func _ready():
	# Not the best way to do this, but works for now
	player = get_tree().get_nodes_in_group("Players")[0]
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))

func _physics_process(delta: float) -> void:
	if player == null:
		return

	look_at(player.global_position)

	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)  # Smooth decay
	else:
		calc_path()

	move_and_slide()

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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass

func on_hit(damage: float, source: Node2D, unavoidable: bool) -> void:
	if not unavoidable and is_invincible:
		return
	take_damage(damage, source)

func take_damage(damage: float, source: Node2D) -> void:
	current_health -= damage
	print("Enemy took ", damage, " dmg")
	$hit_sound.play()
	DamageNumbers.display_number(floor(damage), global_position)
	
	# Technically we should use the position of the hit itself, not the player position, but whatever
	var knockback_direction = (global_position - source.global_position).normalized()
	knockback_velocity = knockback_direction * damage * self_knockback_multiplier

	if current_health <= 0:
		die()
	else:
		start_invincibility()

func die():
	sfx_manager.stream = death_sfx
	sfx_manager.play()
	enemy_dead.emit(self)
	queue_free()

func start_invincibility():
	is_invincible = true
	$invincibility_timer.start()
	if not $invincibility_timer.timeout.is_connected(end_invincibility):
		$invincibility_timer.timeout.connect(end_invincibility)
	modulate_sprites(Color(1, 1, 1, 0.5))

func end_invincibility():
	is_invincible = false
	modulate_sprites(Color(1, 1, 1, 1))

# We don't have to show vulnerability this way - we can do other ways. This shade of white is just obvious for now.
# Slightly white shade to show invincibility
func modulate_sprites(color: Color):
	var sprites = find_children("", "Sprite2D")
	#var sprites = get_children().filter(func(child): return child is Sprite2D) # Use this if you only want direct children, no descendents.
	for sprite in sprites:
		sprite.modulate = color

# Debug func to see detection radius
func _draw():
	if (!SHOW_DETECTION_RADIUS):
		return
	draw_circle(Vector2.ZERO, detection_radius, Color(1, 0, 0, 0.5))

func _on_weapon_hitbox_area_entered(object_hit: Area2D) -> void:
	if (object_hit.has_method("process_hit")):
		object_hit.process_hit(damage, self, false)
