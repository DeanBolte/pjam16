extends Area2D
class_name PlayerCameraAnchor

@export var WIDTH: int
@export var HEIGHT: int


func _on_body_entered(body: Node2D) -> void:
	Signals.player_entered_room.emit(global_position, Vector2i(WIDTH, HEIGHT))
