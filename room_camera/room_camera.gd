extends Camera2D

func _ready() -> void:
	Signals.player_entered_room.connect(_move_camera_to_player)

func _move_camera_to_player(new_position: Vector2):
	global_position = new_position
