extends Camera2D

@onready var LevelFader = $Control/LevelFader
@onready var TransitionPlayer = $TransitionPlayer

func _ready() -> void:
	Signals.player_entered_room.connect(_move_camera_to_player)
	Signals.player_reached_level_transition.connect(_fade_into_level)

func _move_camera_to_player(new_position: Vector2):
	global_position = new_position

func _fade_into_level():
	LevelFader.visible = true
	TransitionPlayer.play("fade_in")
	#get_tree().paused = true

func _transition_complete() -> void:
	LevelFader.visible = false
	get_tree().paused = false
