extends Node2D

func _ready() -> void:
	Signals.player_hit.connect(_play_fart)

func _play_fart(hit_by: Area2D, hit_location: Vector2):
	$audio_player.play()
