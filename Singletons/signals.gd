extends Node2D

signal player_entered_room(new_position: Vector2)
signal player_hit(hit_by: Area2D)
signal enemy_killed()
signal select_upgrade(upgrades: Array[ItemData])
