extends Node2D

@onready var OpenSprite := $OpenSprite
@onready var ClosedSprite := $ClosedSprite

var _is_open := false

func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if _is_open:
		Signals.player_reached_level_transition.emit()
	else:
		open_transition()


func open_transition() -> void:
	_is_open = true
	OpenSprite.visible = true
	ClosedSprite.visible = false
