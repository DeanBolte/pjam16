extends Node
class_name RoomFactory

const STARTING_LOCATION = Vector2i.ZERO

@export var _rooms_node: Node2D


static func new_factory(rooms_node: Node2D) -> RoomFactory:
	var factory := RoomFactory.new()
	factory.set_rooms_node(rooms_node)

	return factory


func _get_random_room_scene(position: Vector2i, is_last: bool = false) -> Room:
	var random = randi() % 100
	var room_type: Room.ROOMS

	if random > 25:
		room_type = Room.ROOMS.BASIC
	else:
		room_type = Room.ROOMS.LONG

	return Room._new_room(position, room_type, is_last)


func get_random_room(position: Vector2i) -> Room:
	var new_room := _get_random_room_scene(position)
	_rooms_node.add_child(new_room)
	new_room.generate()
	return new_room

func get_random_starting_room() -> Room:
	var new_room := _get_random_room_scene(STARTING_LOCATION)
	_rooms_node.add_child(new_room)
	new_room.generate()
	return new_room

func get_random_final_room(position: Vector2i) -> Room:
	var new_room := _get_random_room_scene(position, true)
	_rooms_node.add_child(new_room)
	new_room.generate()
	return new_room

func get_boss_room(position: Vector2i) -> Room:
	var new_room = Room._new_room(position, Room.ROOMS.BOSS, false)
	_rooms_node.add_child(new_room)
	new_room.generate()
	return new_room

func get_rooms_node() -> Node2D:
	return _rooms_node

func set_rooms_node(rooms_node: Node2D) -> void:
	_rooms_node = rooms_node
