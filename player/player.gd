extends CharacterBody2D

const BASE_SPEED = 20
const MAX_SPEED = 600
const SPEED_MULTIPLIER = 2
const ROTATION_SPEED = 0.5

@export var rotation_speed: float = 0.8
@export var max_speed: int = 600
@export var base_speed: int = 20
@export var speed_multiplier = 2

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_direction = global_position.direction_to(mouse_position)
	var distanceFromMouse = $sword_tip.global_position.distance_to(mouse_position)

	if Input.is_action_pressed("stop_moving"):
		velocity = Vector2(0, 0)
	else:
		velocity = mouse_direction * min(max_speed, (distanceFromMouse + base_speed) * speed_multiplier)

	if distanceFromMouse > 20 and global_position.distance_to(mouse_position) > 20:
		rotation = lerp_angle(rotation, mouse_direction.angle(), rotation_speed)
		move_and_slide()
