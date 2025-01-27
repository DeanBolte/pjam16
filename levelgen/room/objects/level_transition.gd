extends Node2D


func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	Signals.player_reached_level_transition.emit()
