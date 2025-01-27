extends Camera2D

const SIDE_BLACK_BAR_OFFSET := 256

@onready var LevelFader = $Control/LevelFader
@onready var TransitionPlayer = $TransitionPlayer

func _ready() -> void:
	Signals.player_entered_room.connect(_move_camera_to_player)
	Signals.player_reached_level_transition.connect(_fade_into_level)

func _move_camera_to_player(new_position: Vector2, limit_dimensions: Vector2i):
	global_position = new_position
	limit_left = -limit_dimensions.x / 2 + new_position.x - SIDE_BLACK_BAR_OFFSET
	limit_right = limit_dimensions.x / 2 + new_position.x + SIDE_BLACK_BAR_OFFSET
	limit_top = -limit_dimensions.y / 2 + new_position.y
	limit_bottom = limit_dimensions.y / 2 + new_position.y

func _fade_into_level():
	LevelFader.visible = true
	TransitionPlayer.play("fade_in")
	#get_tree().paused = true

func _transition_complete() -> void:
	LevelFader.visible = false
	get_tree().paused = false
