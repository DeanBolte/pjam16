extends CharacterBody2D

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")

# During boss fight, boss spawns crates around himself to throw at player.
const SHOW_CRATE_SPAWN_RADIUS := false
const CRATE_SPAWN_RADIUS: int = 400
const CRATE_SPAWN_AMT: int = 3
const CRATE_SPAWN_REGION_SIZE: Vector2 = Vector2(200, 400) # Set size manually
const CRATE_THROW_COOLDOWN := 2 # in seconds
const CRATE_THROW_SPEED = 5000.0 # Adjust based on gameplay balance

# If player gets too close, boss will 'swat' them away, dealing damage and applying knockback.
const SHOW_SWAT_RADIUS := true
const SWAT_RADIUS: int = 300

@onready var sfx_manager = get_node("../../../../SfxManager")
@onready var death_sfx = preload("res://assets/sounds/enemies/enemy_death.wav")

@export var max_health: float = 250
@export var current_health: float = max_health
@export var speed: int = 10000
@export var invincibility_time: float = 1 # seconds of invincibility after being hit
@export var damage: float = 5
@export var swat_knockback_damage := 5
@export var swat_knockback_force := 7500.0
@export var crate_spawn_area: Node2D

var is_invincible: bool = false
var player: CharacterBody2D = null
var distance_to_player: float = 0
var can_throw_crate := true

signal enemy_dead(enemy: CharacterBody2D)

func _ready():
	# Not the best way to do this, but works for now
	player = get_tree().get_nodes_in_group("Players")[0]
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))
	
func _process(delta: float) -> void:
	if player == null:
		return
	distance_to_player = global_position.distance_to(player.global_position)
	look_at(player.global_position)
	
	if (distance_to_player <= SWAT_RADIUS):
		_swat_player()
	_throw_crates_at_player()
	
	_delete_bad_crates()

func _swat_player() -> void:
	# 'Rotate' the boss to imitate a swing
	_swing_body()

	# Check, just in case
	if (player.has_method("on_hit_by_enemy")):
		player.on_hit_by_enemy(swat_knockback_damage, self)
	var knockback_direction = (player.global_position - global_position).normalized()
	player.knockback_velocity = knockback_direction * swat_knockback_force

func _throw_crates_at_player() -> void:
	if not can_throw_crate:
		return

	for crate in get_tree().get_nodes_in_group("Crates"):
		var crate_in_range = global_position.distance_to(crate.global_position) <= CRATE_SPAWN_RADIUS
		if crate_in_range and crate.has_method("throw_at") and crate.last_touched_by != "sword_edge_hitbox":
			crate.throw_at(player.global_position, CRATE_THROW_SPEED)
			can_throw_crate = false
			await get_tree().create_timer(CRATE_THROW_COOLDOWN).timeout
			can_throw_crate = true
			break

func _spawn_crates() -> void:
	# before spawning, check if there is a crate still in the spawn zone for the boss to throw.
	var crates_in_spawn_area = _get_crates_in_spawn_area()
	if (crates_in_spawn_area.size() > 0):
		return

	for i in range(CRATE_SPAWN_AMT):
		var crate := CRATE_RESOURCE.instantiate()

		# Pick a random position inside the spawn area
		var random_offset = Vector2(
			randf_range(-CRATE_SPAWN_REGION_SIZE.x / 2, CRATE_SPAWN_REGION_SIZE.x / 2),
			randf_range(-CRATE_SPAWN_REGION_SIZE.y / 2, CRATE_SPAWN_REGION_SIZE.y / 2)
		)
		crate.global_position = crate_spawn_area.global_position + random_offset
		get_tree().get_root().add_child(crate)

func _get_crates_in_spawn_area() -> Array[Node]:
	var crates = get_tree().get_nodes_in_group("Crates")
	var crates_in_spawn_area = crates.filter(func(crate):
		return crate_spawn_area.global_position.distance_to(crate.global_position) <= CRATE_SPAWN_REGION_SIZE.length() / 2
	)
	return crates_in_spawn_area

func on_hit(damage: float) -> void:
	if is_invincible:
		return
	take_damage(damage)

func take_damage(damage: float) -> void:
	current_health -= damage
	print("Boss took ", damage, " dmg. Remaining hp: ", current_health)
	$hit_sound.play()
	DamageNumbers.display_number(floor(damage), global_position)

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

func modulate_sprites(color: Color):
	var sprites = find_children("", "Sprite2D")
	for sprite in sprites:
		sprite.modulate = color

func _swing_body() -> void:
	var tween = get_tree().create_tween()
	# Rotate 60 counterclockwise, in 0.2s
	tween.tween_property(self, "rotation_degrees", rotation_degrees - 90, 0.3).set_trans(Tween.TRANS_QUAD)
	# Rotate back to original, after 0.5s
	tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.6).set_delay(1).set_trans(Tween.TRANS_QUAD)

func _draw():
	if (SHOW_CRATE_SPAWN_RADIUS):
		draw_circle(Vector2.ZERO, CRATE_SPAWN_RADIUS, Color(0, 0, 1, 0.5))

# Crates get stuck sometimes in the spawn area. So, clean them up when needed
func _delete_bad_crates() -> void:
	var crates_in_spawn_area = _get_crates_in_spawn_area()
	for crate in crates_in_spawn_area:
		if crate.is_eligible_to_delete(5):
			crate.queue_free()
