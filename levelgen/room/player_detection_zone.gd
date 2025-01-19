extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Signals.player_entered_room.emit(global_position)
