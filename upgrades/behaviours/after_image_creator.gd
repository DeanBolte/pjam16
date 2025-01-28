extends Node2D

@export var ACCEPTABLE_DIFF = 0.02
@export var MIN_DISTANCE = 150
@export var AFTER_IMAGE_SCENE = preload("res://upgrades/behaviours/after_image.tscn")

var prev_location = null
var current_direction = null
var total_distance = 0
var on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.player_moved.connect(player_moved)


func player_moved(player: Node2D):
	var location = player.global_position
	
	if prev_location != null:
		if current_direction == null:
			current_direction = prev_location.direction_to(location)
		else:
			var new_direction = prev_location.direction_to(location)
			var diff = current_direction - new_direction
			if abs(diff.x) < ACCEPTABLE_DIFF and abs(diff.y) < ACCEPTABLE_DIFF:
				total_distance += prev_location.distance_to(location)
				if total_distance >= MIN_DISTANCE:
					total_distance = 0
					if not on_cooldown:
						on_cooldown = true
						print("Spawn after image")
						var after_image = AFTER_IMAGE_SCENE.instantiate()
						after_image.transform = GlobalReferences.weapon_reference.global_transform
						after_image.direction = current_direction
						call_deferred("add_child", after_image)
						$cooldown.start()
			else:
				total_distance = 0
			current_direction = new_direction
				
				
	prev_location = location


func _on_cooldown_timeout() -> void:
	on_cooldown = false
