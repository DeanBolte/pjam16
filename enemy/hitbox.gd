extends Area2D

func _on_area_entered(other: Area2D) -> void:
	get_parent().on_hit()
