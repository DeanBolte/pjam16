extends CharacterBody2D

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")

# During boss fight, boss spawns crates around himself to throw at player.
const SHOW_CRATE_SPAWN_RADIUS := true
const CRATE_SPAWN_RADIUS: int = 400
const CRATE_SPAWN_AMT: int = 3

# If player gets too close, boss will 'swat' them away, dealing damage and applying knockback.
const SHOW_SWAT_RADIUS := true
const SWAT_RADIUS: int = 300

@onready var sfx_manager = get_node("../../../../SfxManager")
@onready var death_sfx = preload("res://audio/sfx/enemy_death.wav")

@export var max_health: float = 100
@export var current_health: float = max_health
@export var speed: int = 10000
@export var invincibility_time: float = 1 # seconds of invincibility after being hit
@export var damage: float = 5
@export var swat_knockback_damage := 5
@export var swat_knockback_force := 7500.0

var is_invincible: bool = false
var player: CharacterBody2D = null
var distance_to_player: float = 0

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

func _swat_player() -> void:
	# 'Rotate' the boss to imitate a swing
	_swing_body()

	# Check, just in case
	if (player.has_method("on_hit_by_enemy")):
		player.on_hit_by_enemy(swat_knockback_damage)
	var knockback_direction = (player.global_position - global_position).normalized()
	player.knockback_velocity = knockback_direction * swat_knockback_force

func _spawn_crates() -> void:
	for i in range(CRATE_SPAWN_AMT):
		var crate := CRATE_RESOURCE.instantiate()
		var random_offset = Vector2(randf_range(-CRATE_SPAWN_RADIUS, CRATE_SPAWN_RADIUS), randf_range(-CRATE_SPAWN_RADIUS, CRATE_SPAWN_RADIUS))
		crate.global_position = global_position + random_offset
		get_parent().add_child(crate)

func on_hit(damage: float) -> void:
	if is_invincible:
		return
	take_damage(damage)

func take_damage(damage: float) -> void:
	current_health -= damage
	print("Boss took ", damage, " dmg")
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

func _on_weapon_hitbox_area_entered(object_hit: Area2D) -> void:
	if (object_hit.has_method("process_hit")):
		object_hit.process_hit(damage)
