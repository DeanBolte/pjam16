extends Area2D

func process_hit(damage: float, source: Node2D, unavoidable: bool) -> void:
	get_parent().on_hit(damage)
