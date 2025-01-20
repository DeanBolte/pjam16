extends Area2D

func process_hit(other: Area2D) -> void:
	get_parent().on_hit()
