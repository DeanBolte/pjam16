extends Node2D
class_name Room

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")

@onready var Objects := $Objects

@export var MAX_CRATES := 40


func _generate_objects() -> void:
	_generate_crates()

func _generate_crates() -> void:
	for crate in MAX_CRATES:
		var instance: Crate = CRATE_RESOURCE.instantiate()
		instance.position = _get_spawn_location()

		Objects.add_child(instance)


func _get_spawn_location() -> Vector2:
	return Vector2.ZERO

func _is_location_free() -> bool:
	return true


func generate() -> void:
	_generate_objects()
