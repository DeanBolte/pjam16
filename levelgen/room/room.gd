extends Node2D
class_name Room

static var ROOM_RESOURCE := preload("res://levelgen/room/room.tscn")
static var LONG_ROOM_RESOURCE := preload("res://levelgen/room/long_room.tscn")

enum ROOMS { BASIC, LONG, CORNER, BIG }

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")
var LEVEL_TRANSITION_RESOURCE := preload("res://levelgen/room/objects/level_transition.tscn")
var ENEMY_RESOURCE = preload("res://enemy/enemy.tscn")

const GRID_WIDTH := 640

@onready var Objects := $Objects
@onready var BaseFloor := $BaseFloor

@export var MIN_CRATES := 1
@export var MAX_CRATES := 5
@export var MIN_ENEMIES := 0
@export var MAX_ENEMIES := 3

@export var SPAWN_AREA_WIDTH: int = 540
@export var SPAWN_AREA_HEIGHT: int = 540

@export var relative_map_positions: Array[Vector2i]
@export var room_doors: Array[Door]

var _map_location: Vector2i
var _is_last_room: bool
var _room_type: ROOMS

var _are_doors_closed: bool = false

static func _new_room(map_location: Vector2i, room_type: ROOMS, is_last_room: bool = false) -> Room:
	var new_room: Room = _get_room_scene(room_type).instantiate()
	new_room.set_map_location(map_location)
	new_room._room_type = room_type
	new_room._is_last_room = is_last_room

	return new_room


static func _get_room_scene(id: ROOMS) -> Resource:
	match id:
		ROOMS.BASIC:
			return ROOM_RESOURCE
		ROOMS.LONG:
			return LONG_ROOM_RESOURCE
		ROOMS.CORNER:
			return LONG_ROOM_RESOURCE
		ROOMS.BIG:
			return LONG_ROOM_RESOURCE
		_:
			return ROOM_RESOURCE

func _generate_objects() -> void:
	_generate_crates()

func _generate_crates() -> void:
	var noOfCrates = randi_range(MIN_CRATES, MAX_CRATES)
	for crate in noOfCrates:
		_spawn_object_randomly(CRATE_RESOURCE.instantiate())

func _generate_enemies() -> void:
	var noOfEnemies = randi_range(MIN_ENEMIES, MAX_ENEMIES)
	for enemy in noOfEnemies:
		_spawn_object_randomly(ENEMY_RESOURCE.instantiate())

func _get_spawn_location() -> Vector2:
	return Vector2(randi() % SPAWN_AREA_WIDTH - SPAWN_AREA_WIDTH / 2, randi() % SPAWN_AREA_HEIGHT - SPAWN_AREA_HEIGHT / 2)

func _is_location_free() -> bool:
	return true

func _generate_level_transition() -> void:
	_spawn_object_randomly(LEVEL_TRANSITION_RESOURCE.instantiate())

func _spawn_object_randomly(instance: Node2D):
	instance.position = _get_spawn_location()
	Objects.add_child(instance)


func generate() -> void:
	_generate_objects()
	_generate_enemies()

	if _is_last_room:
		_generate_level_transition()

func close_doors(door_locations: Array[Vector2i]) -> void:
	if _are_doors_closed:
		return

	for door: Door in room_doors.filter(func(d: Door): return door_locations.has(d.relative_next_room_position)):
		door.enabled = true

	_are_doors_closed = true

func get_relative_next_room_locations() -> Array[Vector2i]:
	var locations: Array[Vector2i]
	locations.assign(room_doors.map(func(d: Door): return d.relative_next_room_position))
	return locations

func are_doors_closed() -> bool:
	return _are_doors_closed

func set_map_location(map_location: Vector2i) -> void:
	self._map_location = map_location
	self.global_position = Vector2(map_location.x * GRID_WIDTH , map_location.y * GRID_WIDTH)

func get_map_location() -> Vector2i:
	return self._map_location

func set_room_type(type: ROOMS) -> void:
	_room_type = type

func get_room_type() -> ROOMS:
	return _room_type

func set_is_last_room(is_last_room: bool) -> void:
	_is_last_room = is_last_room

func is_last_room() -> bool:
	return _is_last_room
