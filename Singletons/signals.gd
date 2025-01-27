extends Node2D

signal health_updated(health: int)
signal player_entered_room(new_position: Vector2, dimensions: Vector2i)
signal player_reached_level_transition()
signal new_level_reached()
signal player_hit(hit_by: Area2D, hit_location: Vector2)
signal enemy_hit(player: Node2D, enemy: Node2D, hit_location: Vector2)
signal player_moved(player: Node2D)
signal enemy_killed()

signal select_upgrade(upgrades: Array[ItemData])
signal apply_upgrade(upgade: ItemData)
