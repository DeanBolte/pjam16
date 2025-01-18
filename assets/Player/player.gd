extends CharacterBody2D

const BASE_SPEED = 20
const MAX_SPEED = 600
const SPEED_MULTIPLIER = 2
const ROTATION_SPEED = 0.5

@export var rotation_speed: float = 0.8
@export var max_speed: int = 600
@export var base_speed: int = 20
@export var speed_multiplier = 2

var mouse_is_in_window = true

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_direction = global_position.direction_to(mouse_position)
	var distanceFromMouse = $sword_tip.global_position.distance_to(mouse_position)

	velocity = mouse_direction * min(max_speed, (distanceFromMouse + base_speed) * speed_multiplier)

	if distanceFromMouse > 20 and mouse_is_in_window:
		if not Input.is_action_pressed("stop_moving"):
			move_and_slide()

		rotation = lerp_angle(rotation, mouse_direction.angle(), rotation_speed)

func _notification(event):
	# TODO We probably wont to remove this later for an actual pause mechanic, I have this here for easier testing.
	match event:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_in_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_in_window = true
