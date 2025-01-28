extends RigidBody2D
class_name Crate

const LIFETIME = 20.0 # Despawn after X time

# Add linear and angular damping variables
const LINEAR_DAMPING = 4  # Adjust for sliding reduction (higher values reduce more)
const ANGULAR_DAMPING = 0.5  # Adjust to reduce rotation speed (higher = slower rotation)

# The minimum speed to break and collide, should be different for the boss and player.
# Its much harder for the player to throw the crate at a fast speed against the boss, hence they should need a lower threshold.
const HITBOX_BREAK_SPEEDS := {
	"peasant_damage_hitbox": 700,
	"boss_main_hitbox": 400
}
const DEFAULT_BREAK_SPEED = 500

const DAMAGE_AGAINST := {
	"peasant_damage_hitbox": 10,
	"boss_main_hitbox": 50,
	"boss_left_hand_hitbox": 10,
	"boss_right_hand_hitbox": 10
}
const DEFAULT_DAMAGE = 10

# When swinging the sword and hitting the crate, if this number is met then reflect the crate back.
const MIN_SWORD_PUSH_SPEED = 500
const SWORD_PUSH_SPEED_MULTIPLIER = 10000

# Kinda jank but keep track of last entity to touch this - useful to prevent enemies from utilising this if player touched it.
var last_touched_by = null
var current_lifetime := 0.0

func _ready():
	# Make sure the crate doesn't fall due to gravity
	sleeping = false  # Wake up the body if it has velocity
	freeze = false
	linear_velocity = Vector2.ZERO
	
	# Apply linear damping to reduce sliding
	linear_damp = LINEAR_DAMPING
	
	# Apply angular damping to reduce rotation speed
	angular_damp = ANGULAR_DAMPING
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = 0.1
	physics_mat.bounce = 0.0
	$CollisionShape2D.set_deferred("physics_material_override", physics_mat)

func _process(delta: float) -> void:
	current_lifetime += delta
	
	if is_eligible_to_delete():
		queue_free()

func throw_at(target_position: Vector2, throw_speed: float):
	# Unfreeze to enable physics movement
	freeze = false

	# Calculate direction
	var direction = (target_position - global_position).normalized()

	# Apply force to launch the crate
	linear_velocity = direction * throw_speed

	# Add a small random angular velocity for slight spin
	angular_velocity = randf_range(-2.0, 2.0)  # Adjust range for desired effect

func is_eligible_to_delete(max_lifetime: float = LIFETIME) -> bool:
	return current_lifetime >= max_lifetime and linear_velocity.length() < 0.1

# If the crate is travelling fast enough and hits an entity, apply damage to that entity and destroy this crate.
func _on_area_2d_area_entered(object_hit: Area2D) -> void:
	var speed = linear_velocity.length()
	last_touched_by = object_hit.name

	var min_break_speed = HITBOX_BREAK_SPEEDS.get(object_hit.name, DEFAULT_BREAK_SPEED)
	if (object_hit.has_method("process_hit") and speed >= min_break_speed):
		var damage = DAMAGE_AGAINST.get(object_hit.name, DEFAULT_DAMAGE)
		object_hit.process_hit(damage, self, false)
		_destroy_self()
	
	# Testing by Duc: If the sword swings fast enough and hits the crate, send the crate with a strong force
	var swing_speed = MouseTracker.get_swipe_speed()
	if swing_speed >= MIN_SWORD_PUSH_SPEED and object_hit.name == "sword_edge_hitbox":
		var direction = (global_position - object_hit.global_position).normalized()
		apply_impulse(direction * SWORD_PUSH_SPEED_MULTIPLIER)

func _destroy_self() -> void:
	_disable_self()
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.connect("finished", Callable(self, "_on_audio_finished"))

func _disable_self() -> void:
	visible = false
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0)

func _on_audio_finished() -> void:
	queue_free()
