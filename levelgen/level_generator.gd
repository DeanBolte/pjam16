extends Node

var ROOM_RESOURCE = preload("res://levelgen/room/room.tscn")

@export var MAX_ROOMS := 30

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

		var location = vacant_rooms.front()
		room.generate(location)
		level_map[location] = room

func _get_room_candidates() -> Array[Vector2i]:
	var vacant_rooms: Array[Vector2i] = []
	for room: Vector2i in level_map.keys():
		if _is_room_vacant(Vector2i(room.x - 1, room.y)):
			vacant_rooms.append(Vector2i(room.x - 1, room.y))
		if _is_room_vacant(Vector2i(room.x + 1, room.y)):
			vacant_rooms.append(Vector2i(room.x + 1, room.y))
		if _is_room_vacant(Vector2i(room.x, room.y + 1)):
			vacant_rooms.append(Vector2i(room.x, room.y + 1))
		if _is_room_vacant(Vector2i(room.x + 1, room.y)):
			vacant_rooms.append(Vector2i(room.x + 1, room.y))
	return vacant_rooms

func _does_room_exist(room_location: Vector2i) -> bool:
	return level_map.has(room_location)

func _is_room_vacant(room_location: Vector2i) -> bool:
	return not level_map.has(room_location)
