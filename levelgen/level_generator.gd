extends Node

var _room_factory: RoomFactory

@export var MAX_ROOMS := 7
@export var RETRY_ROOM_ADJACENCY_ATTEMPTS = 4
@export var ROOM_ADJACENCYRETRY_SCALAR = 3
@export var MINIMUM_ADJACENT_ROOMS = 2

# a Map of 2D Vector keys representing the room grid
var level_map: Dictionary = {}
var _rooms_node: Node2D
var level := 1

func _ready() -> void:
	_room_factory = RoomFactory.new_factory(_get_rooms_node())

	_generate_map()

	Signals.player_reached_level_transition.connect(_next_level)

# ------- map generation
func _generate_map() -> void:
	# create new container for rooms
	_room_factory.set_rooms_node(_get_new_rooms_node())

	# add start room
	_add_room(_room_factory.get_random_starting_room())

	# generate main set of rooms
	while MAX_ROOMS - level_map.size() > 1:
		_add_room(_room_factory.get_random_room(_get_next_room_candidate()))

	# generate final room
	_add_room(_room_factory.get_random_final_room(_get_next_room_candidate()))

	_enclose_map()

func _get_rooms_node() -> Node2D:
	if _rooms_node == null:
		_rooms_node = Node2D.new()
		add_child(_rooms_node)
	return _rooms_node

func _get_new_rooms_node() -> Node2D:
	if _rooms_node != null:
		_rooms_node.free()
	_rooms_node = Node2D.new()
	add_child(_rooms_node)
	return _rooms_node

func _add_room(room: Room) -> void:
	var room_candidates: Array[Vector2i] = _get_next_room_candidates()
	var locations: Array[Vector2i] = _get_map_locations(room)
	while locations.any(func(l): return level_map.has(l)):
		room.set_map_location(room_candidates.pop_back())
		locations = _get_map_locations(room)

	for location in locations:
		level_map[location] = room

func _get_map_locations(room: Room) -> Array[Vector2i]:
	var locations: Array[Vector2i]
	locations.assign(room.relative_map_positions.map(func(p): return p + room.get_map_location()))
	return locations

func _enclose_map() -> void:
	# Shut all open doorways to prevent player exiting map
	for room: Room in level_map.values():
		var closedDoors: Array[Vector2i]
		closedDoors.assign(room.get_relative_next_room_locations().filter(func(rel): return _is_room_vacant(rel + room.get_map_location())))
		room.close_doors(closedDoors)

func _has_minimum_number_of_adjacent_vacant_rooms(location: Vector2i) -> bool:
	return not _get_adjacent_vacant_rooms(location).size() < ROOM_ADJACENCYRETRY_SCALAR

func _get_room_candidates() -> Array[Vector2i]:
	var vacant_rooms: Array[Vector2i] = []
	for room: Vector2i in level_map.keys():
		var adjacent_rooms = _get_adjacent_vacant_rooms(room)
		if adjacent_rooms.size() >= MINIMUM_ADJACENT_ROOMS:
			vacant_rooms.append_array(adjacent_rooms)
	return vacant_rooms

func _get_next_room_candidate() -> Vector2i:
	var vacant_rooms := _get_next_room_candidates()
	return vacant_rooms.front()

func _get_next_room_candidates() -> Array[Vector2i]:
	var vacant_rooms := _get_room_candidates().filter(_has_minimum_number_of_adjacent_vacant_rooms)
	if vacant_rooms.is_empty():
		vacant_rooms = _get_room_candidates()
	vacant_rooms.shuffle()
	return vacant_rooms

func _get_adjacent_vacant_rooms(room: Vector2i) -> Array[Vector2i]:
	var vacant_rooms: Array[Vector2i] = []
	for adjacent_room in _get_adjacent_rooms(room):
		if _is_room_vacant(adjacent_room):
			vacant_rooms.append(adjacent_room)
	return vacant_rooms

func _get_adjacent_vacant_room_directions(room: Vector2i) -> Array[Vector2i]:
	var adjacent_rooms: Array[Vector2i]
	adjacent_rooms.assign(_get_adjacent_vacant_rooms(room).map(func(r): return Vector2i(r.x - room.x, r.y - room.y)))
	return adjacent_rooms

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

func _next_level() -> void:
	_destroy_level()
	call_deferred("_generate_map")

	level += 1
	Signals.new_level_reached.emit()

func _destroy_level() -> void:
	_rooms_node.queue_free()
	level_map = {}
