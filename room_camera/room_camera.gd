extends Camera2D
class_name RoomCamera

const SIDE_BLACK_BAR_OFFSET := 256
const BOSS_CAMERA_ZOOM := Vector2(0.6, 0.6)
const NORMAL_CAMERA_ZOOM := Vector2(1, 1)

enum ZOOM_TYPE { NORMAL, BOSS }

@onready var LevelFader = $Control/LevelFader
@onready var TransitionPlayer = $TransitionPlayer

func _ready() -> void:
	Signals.player_entered_room.connect(_move_camera_to_player)
	Signals.player_reached_level_transition.connect(_fade_into_level)

func _move_camera_to_player(new_position: Vector2, limit_dimensions: Vector2i, zoom_type: ZOOM_TYPE):
	zoom = _get_camera_zoom(zoom_type)

	global_position = new_position
	limit_left = -limit_dimensions.x / 2 + new_position.x - SIDE_BLACK_BAR_OFFSET * (1 / zoom.x)
	limit_right = limit_dimensions.x / 2 + new_position.x + SIDE_BLACK_BAR_OFFSET * (1 / zoom.x)
	limit_top = -limit_dimensions.y / 2 + new_position.y
	limit_bottom = limit_dimensions.y / 2 + new_position.y

	# This should be somewhere else, but cbs.
	if (zoom_type == ZOOM_TYPE.BOSS):
		var music_player = get_tree().get_root().find_child("MusicPlayer", true, false)
		if (music_player):
			music_player.stop()


func _fade_into_level():
	TransitionPlayer.play("fade_in")
	get_tree().paused = true

func _transition_complete() -> void:
	get_tree().paused = false

func _get_camera_zoom(zoom_type: ZOOM_TYPE) -> Vector2:
	match zoom_type:
		ZOOM_TYPE.NORMAL:
			return NORMAL_CAMERA_ZOOM
		ZOOM_TYPE.BOSS:
			return BOSS_CAMERA_ZOOM
		_:
			return NORMAL_CAMERA_ZOOM
