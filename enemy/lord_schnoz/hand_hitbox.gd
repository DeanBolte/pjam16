extends Area2D

# Hands take less damage
func process_hit(damage: float) -> void:
	var reduced_damage = damage * 0.66
	get_parent().on_hit(reduced_damage)
