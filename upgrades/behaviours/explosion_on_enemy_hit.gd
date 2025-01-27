extends Node2D

var EXPLOSION_SCENE = preload("res://upgrades/behaviours/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.enemy_hit.connect(_spawn_explosion)

func _spawn_explosion(player: Node2D, enemy: Node2D, hit_location: Vector2):
	var explosion = EXPLOSION_SCENE.instantiate()
	explosion.position = hit_location
	call_deferred("add_child", explosion)
	
