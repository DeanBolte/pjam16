extends CharacterBody2D

@onready var game_over_popup = get_node("../UserInterface/GameOverPopup")
@onready var death_sfx = preload("res://assets/sounds/player/game_over.wav")

const BASE_SPEED = 20
const MAX_SPEED = 600
const SPEED_MULTIPLIER = 2
const ROTATION_SPEED = 0.5
const TAKE_DAMAGE_SOUNDS = [
	preload("res://assets/sounds/player/take_damage/do_something.wav"),
	preload("res://assets/sounds/player/take_damage/help_me.wav"),
	preload("res://assets/sounds/player/take_damage/ow.wav"),
	preload("res://assets/sounds/player/take_damage/owww.wav"),
	preload("res://assets/sounds/player/take_damage/yeowch.wav"),
]

@export var max_health: float = 100
const START_POSITION = Vector2.ZERO

@export var current_health: float = max_health
@export var rotation_speed: float = 0.2
@export var max_speed: int = 570
@export var base_speed: int = 20
@export var speed_multiplier = 1.5
@export var invincibility_time: float = 1 # seconds of invincibility after being hit

@export var damage: float = 10
@export var swipe_speed_damage_multiplier: float = 0.01 # keep in mind, these values can be as high as 3000.
@export var max_added_swipe_damage: float = 100 # Not sure if this is best, but the swipe damage + weird mouse stuff can potentially cause extremely high numbers. So, cap it.

var is_invincible: bool = false
var can_play_take_damage_sound: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO # This STORES knockback force and gradually decreases over timer

var hands_starting_x = 0

func _ready() -> void:
	GlobalReferences.player_reference = self
	hands_starting_x = $hands.position.x
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))
	Signals.apply_upgrade.connect(_apply_upgrade)

	Signals.new_level_reached.connect(_reset_player_position.bind(START_POSITION))


func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_direction = global_position.direction_to(mouse_position)
	var distanceFromMouse = $weapon.get_weapon_tip().distance_to(mouse_position)
	
	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)  # Smooth decay
		move_and_slide()

	var speed = 0
	if not Input.is_action_pressed("stop_moving"):
		speed = min(max_speed, (distanceFromMouse + base_speed) * speed_multiplier)
	velocity = mouse_direction * speed
	$weapon.offset_weapon(speed / 30)
	$hands.position.x = hands_starting_x + (speed / 30)

	if distanceFromMouse > 20 and global_position.distance_to(mouse_position) > 20:
		rotation = lerp_angle(rotation, mouse_direction.angle(), rotation_speed)
		Signals.player_moved.emit(self)
		if not Input.is_action_pressed("stop_moving"):
			move_and_slide()

func _reset_player_position(reset_position: Vector2):
	position = reset_position
	Signals.player_moved.emit(self)

func _apply_upgrade(upgrade: ItemData):
	if(upgrade.weapon_length):
		$weapon.change_weapon_length(upgrade.weapon_length)
	if(upgrade.weapon_width):
		$weapon.change_weapon_width(upgrade.weapon_width)
	if(upgrade.move_speed):
		base_speed += max(upgrade.move_speed * 2, 20)
		speed_multiplier += upgrade.move_speed / 20
		max_speed += max(upgrade.move_speed * 2 * speed_multiplier, 1)
	if(upgrade.damage):
		damage += upgrade.damage
	if(upgrade.swing_speed):
		rotation_speed += upgrade.swing_speed / 50

func _on_weapon_hit(object_hit: Area2D, intersection_point: Vector2) -> void:
	if object_hit.has_method("process_hit"):
		var added_swipe_damage = clamp(MouseTracker.get_swipe_speed() * swipe_speed_damage_multiplier, 0.0, max_added_swipe_damage)
		var total_damage = damage + added_swipe_damage
		object_hit.process_hit(total_damage, self, false)
		Signals.enemy_hit.emit(self, object_hit, intersection_point)
	elif object_hit.has_method("pick_up"):
		object_hit.pick_up()

func on_hit_by_enemy(damage: float, source: Node2D) -> void:
	if is_invincible:
		return

	current_health -= damage
	if current_health <= 0:
		die()
	else:
		DamageNumbers.display_number(floor(damage), global_position)
		start_invincibility()
		if can_play_take_damage_sound:
			play_random_take_damage_sound()
	Signals.health_updated.emit(current_health)

func die():
	SfxManager.stream = death_sfx
	SfxManager.play()
	game_over_popup.visible = true
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

func play_random_take_damage_sound() -> void:
	can_play_take_damage_sound = false
	var random_sound = TAKE_DAMAGE_SOUNDS.pick_random()
	$take_damage/voiceline_cooldown_timer.start()
	$take_damage/voiceline_player.stream = random_sound
	$take_damage/voiceline_player.play()

func _on_sound_timer_timeout() -> void:
	can_play_take_damage_sound = true


func _on_peasant_damage_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.has_method("pick_up"):
		area.pick_up()
	else:
		var body_shape2d: Shape2D = area.shape_owner_get_shape(area_shape_index, 0)
		var area_shape2d: Shape2D = $peasant/peasant_damage_hitbox.shape_owner_get_shape(local_shape_index, 0)

		var body_shape2d_transform = area.shape_owner_get_owner(local_shape_index).get_global_transform()
		var area_shape2d_transform = $peasant/peasant_damage_hitbox.shape_owner_get_owner(area_shape_index).get_global_transform()

		var collision_points = area_shape2d.collide_and_get_contacts(area_shape2d_transform, body_shape2d, body_shape2d_transform)

		var collision_sum = Vector2(0, 0)
		for point in collision_points:
			collision_sum += point
		var average_collision_point = collision_sum / collision_points.size()
		Signals.player_hit.emit(area, average_collision_point)
