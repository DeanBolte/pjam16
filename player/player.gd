extends CharacterBody2D

const BASE_SPEED = 20
const MAX_SPEED = 600
const SPEED_MULTIPLIER = 2
const ROTATION_SPEED = 0.5

@export var rotation_speed: float = 0.8
@export var max_speed: int = 600
@export var base_speed: int = 20
@export var speed_multiplier = 2

var sword_starting_x = 0
var hands_starting_x = 0

func _ready() -> void:
	sword_starting_x = $weapon.position.x
	hands_starting_x = $hands.position.x

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
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			$weapon.increase_weapon_length(0.25)
		elif event.keycode == KEY_2:
			$weapon.decrease_weapon_length(0.25)
		elif event.keycode == KEY_3:
			$weapon.increase_weapon_width(0.25)
		elif event.keycode == KEY_4:
			$weapon.decrease_weapon_width(0.25)
	


func _on_weapon_hit(object_hit: Area2D) -> void:
	Signals.player_sword_hit.emit(object_hit)


func _on_peasant_damage_hitbox_area_entered(area: Area2D) -> void:
	Signals.player_hit.emit(area)
