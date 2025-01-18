extends Node2D
class_name Room

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")
var LEVEL_TRANSITION_RESOURCE := preload("res://levelgen/room/objects/level_transition.tscn")

var ROOM_WIDTH := 640
var ROOM_HEIGHT := 640

@onready var Objects := $Objects
@onready var LeftDoor := $LeftDoor
@onready var RightDoor := $RightDoor
@onready var BottomDoor := $BottomDoor
@onready var TopDoor := $TopDoor

@export var MAX_CRATES := 4

@export var SPAWN_AREA_WIDTH: int
@export var SPAWN_AREA_HEIGHT: int

var _leftDoorConnected := true
var _rightDoorConnected := true
var _topDoorConnected := true
var _bottomDoorConnected := true

func _generate_objects() -> void:
	_generate_crates()

func _generate_crates() -> void:
	for crate in MAX_CRATES:
		_spawn_object_randomly(CRATE_RESOURCE.instantiate())

func _get_spawn_location() -> Vector2:
	return Vector2(randi() % SPAWN_AREA_WIDTH - SPAWN_AREA_WIDTH / 2, randi() % SPAWN_AREA_HEIGHT - SPAWN_AREA_HEIGHT / 2)

func _is_location_free() -> bool:
	return true

func _generate_level_transition() -> void:
	_spawn_object_randomly(LEVEL_TRANSITION_RESOURCE.instantiate())

func _spawn_object_randomly(instance: Node2D):
	instance.position = _get_spawn_location()
	Objects.add_child(instance)


func generate(location: Vector2i, is_last_room: bool) -> void:
	global_position = Vector2(location.x * ROOM_WIDTH , location.y * ROOM_HEIGHT)

	_generate_objects()

	if is_last_room:
		_generate_level_transition()

func close_doors(door_locations: Array[Vector2i]) -> void:
	TopDoor.enabled = door_locations.has(Vector2i.UP)
	BottomDoor.enabled = door_locations.has(Vector2i.DOWN)
	RightDoor.enabled = door_locations.has(Vector2i.RIGHT)
	LeftDoor.enabled = door_locations.has(Vector2i.LEFT)
