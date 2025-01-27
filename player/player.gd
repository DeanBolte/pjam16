extends CharacterBody2D

@onready var game_over_popup = get_node("../UserInterface/GameOverPopup")
@onready var sfx_manager = get_node("../SfxManager")
@onready var death_sfx = preload("res://audio/sfx/game_over.wav")

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

@export var max_health: float = 50
@export var current_health: float = max_health
@export var rotation_speed: float = 0.8
@export var max_speed: int = 600
@export var base_speed: int = 20
@export var speed_multiplier = 2
@export var invincibility_time: float = 1 # seconds of invincibility after being hit

@export var damage: float = 10
@export var swipe_speed_damage_multiplier: float = 0.01 # keep in mind, these values can be as high as 3000.
@export var max_added_swipe_damage: float = 100 # Not sure if this is best, but the swipe damage + weird mouse stuff can potentially cause extremely high numbers. So, cap it.

var is_invincible: bool = false
var can_play_take_damage_sound: bool = true

var sword_starting_x = 0
var hands_starting_x = 0

func _ready() -> void:
	sword_starting_x = $weapon.position.x
	hands_starting_x = $hands.position.x
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))
	Signals.apply_upgrade.connect(_apply_upgrade)

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_direction = global_position.direction_to(mouse_position)
	var distanceFromMouse = $weapon.get_weapon_tip().distance_to(mouse_position)

	var speed = 0
	if not Input.is_action_pressed("stop_moving"):
		speed = min(max_speed, (distanceFromMouse + base_speed) * speed_multiplier)
	velocity = mouse_direction * speed
	$weapon.offset_weapon(speed / 30)
	$hands.position.x = hands_starting_x + (speed / 30)

	if distanceFromMouse > 20 and global_position.distance_to(mouse_position) > 20:
		rotation = lerp_angle(rotation, mouse_direction.angle(), rotation_speed)
		move_and_slide()
		Signals.player_moved.emit(self)
			
func _apply_upgrade(upgrade: ItemData):
	if(upgrade.weapon_length):
		$weapon.change_weapon_length(upgrade.weapon_length)
	if(upgrade.weapon_width):
		$weapon.change_weapon_width(upgrade.weapon_width)
	if(upgrade.move_speed):
		base_speed += upgrade.move_speed
		max_speed += upgrade.move_speed * speed_multiplier
	if(upgrade.damage):
		damage += upgrade.damage
	if(upgrade.swing_speed):
		rotation_speed += upgrade.swing_speed / 50

func _on_weapon_hit(object_hit: Area2D) -> void:
	if object_hit.has_method("process_hit"):
		var added_swipe_damage = clamp(MouseTracker.get_swipe_speed() * swipe_speed_damage_multiplier, 0.0, max_added_swipe_damage)
		var total_damage = damage + added_swipe_damage
		object_hit.process_hit(total_damage)
		Signals.enemy_hit.emit(self, object_hit, null) # TODO Get the intersection point
	elif object_hit.has_method("pick_up"):
		object_hit.pick_up()

func _on_peasant_damage_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("pick_up"):
		area.pick_up()
	else:	
		var intersection_point = (self.global_position + area.global_position) / 2
		 # TODO This intersection point is not even close to accurate and I give up trying to find 
		# the correct one. 
		Signals.player_hit.emit(area, intersection_point)

func on_hit_by_enemy(damage: float) -> void:
	if is_invincible:
		return

	current_health -= damage
	if current_health <= 0:
		die()
	else:
		start_invincibility()
		if can_play_take_damage_sound:
			play_random_take_damage_sound()
	Signals.health_updated.emit(current_health)
	print("peasant took damage, current_health: ", current_health)

func die():
	sfx_manager.stream = death_sfx
	sfx_manager.play()
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
