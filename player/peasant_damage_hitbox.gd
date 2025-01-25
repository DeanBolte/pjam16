extends Area2D

# Not the best way to get the player root node, but it works.
func process_hit(damage: float) -> void:
	find_parent("player").on_hit_by_enemy(damage)
