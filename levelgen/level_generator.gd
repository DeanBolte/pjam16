extends Node

var ROOM_RESOURCE = preload("res://levelgen/room/room.tscn")

@export var MAX_ROOMS := 30
@export var RETRY_ROOM_ADJACENCY_ATTEMPTS = 4
@export var ROOM_ADJACENCYRETRY_SCALAR = 3
@export var MINIMUM_ADJACENT_ROOMS = 2

# a Map of 2D Vector keys representing the room grid
var level_map: Dictionary = {}


func _ready() -> void:
	var base_room: Room = ROOM_RESOURCE.instantiate()
	add_child(base_room)

	base_room.generate(Vector2i.ZERO)
	level_map[Vector2i.ZERO] = base_room

	_generate_map()

# ------- map generation
func _generate_map() -> void:
	while MAX_ROOMS - level_map.size() > 0:
		var vacant_rooms := _get_room_candidates()
		vacant_rooms.shuffle()

		var room: Room = ROOM_RESOURCE.instantiate()
		add_child(room)

		if (not vacant_rooms.is_empty()):
			var location = vacant_rooms.front()

			for r in RETRY_ROOM_ADJACENCY_ATTEMPTS:
				if (_get_adjacent_vacant_rooms(location).size() < ROOM_ADJACENCYRETRY_SCALAR):
					vacant_rooms.shuffle()
					location = vacant_rooms.front()

			room.generate(location)
			level_map[location] = room

func _get_room_candidates() -> Array[Vector2i]:
	var vacant_rooms: Array[Vector2i] = []
	for room: Vector2i in level_map.keys():
		var adjacent_rooms = _get_adjacent_vacant_rooms(room)
		if adjacent_rooms.size() >= MINIMUM_ADJACENT_ROOMS:
			vacant_rooms.append_array(adjacent_rooms)
	return vacant_rooms

func _get_adjacent_vacant_rooms(room: Vector2i) -> Array[Vector2i]:
	var vacant_rooms: Array[Vector2i] = []
	for adjacent_room in _get_adjacent_rooms(room):
		if _is_room_vacant(adjacent_room):
			vacant_rooms.append(adjacent_room)
	return vacant_rooms

func _get_adjacent_rooms(room: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(room.x - 1, room.y),
		Vector2i(room.x +1, room.y),
		Vector2i(room.x, room.y - 1),
		Vector2i(room.x, room.y + 1)
	]

func _does_room_exist(room_location: Vector2i) -> bool:
	return level_map.has(room_location)

func _is_room_vacant(room_location: Vector2i) -> bool:
	return not level_map.has(room_location)
