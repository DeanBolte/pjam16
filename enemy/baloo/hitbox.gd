extends Area2D

func process_hit(damage: float) -> void:
	get_parent().on_hit(damage)
