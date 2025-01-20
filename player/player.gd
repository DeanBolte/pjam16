extends CharacterBody2D

const BASE_SPEED = 20
const MAX_SPEED = 600
const SPEED_MULTIPLIER = 2
const ROTATION_SPEED = 0.5

const START_POSITION = Vector2.ZERO

@export var rotation_speed: float = 0.8
@export var max_speed: int = 600
@export var base_speed: int = 20
@export var speed_multiplier = 2

var sword_starting_x = 0

func _ready() -> void:
	sword_starting_x = $sword.position.x

	Signals.new_level_reached.connect(_reset_player_position.bind(START_POSITION))


func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_direction = global_position.direction_to(mouse_position)
	var distanceFromMouse = $sword_tip.global_position.distance_to(mouse_position)

	var speed = 0
	if not Input.is_action_pressed("stop_moving"):
		speed = min(max_speed, (distanceFromMouse + base_speed) * speed_multiplier)
	velocity = mouse_direction * speed
	$sword.position.x = sword_starting_x + (speed / 30)

	if distanceFromMouse > 20 and global_position.distance_to(mouse_position) > 20:
		rotation = lerp_angle(rotation, mouse_direction.angle(), rotation_speed)
		move_and_slide()

func _reset_player_position(reset_position: Vector2):
	position = reset_position
