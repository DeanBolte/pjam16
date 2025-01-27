extends Node
class_name RoomFactory

const STARTING_LOCATION = Vector2i.ZERO

@export var _rooms_node: Node2D


static func new_factory(rooms_node: Node2D) -> RoomFactory:
	var factory := RoomFactory.new()
	factory.set_rooms_node(rooms_node)

	return factory

func get_random_room(position: Vector2i) -> Room:
	var new_room := Room._new_room([position])
	_rooms_node.add_child(new_room)
	new_room.generate(position, false)
	return new_room

func get_random_starting_room() -> Room:
	var new_room := Room._new_room([STARTING_LOCATION])
	_rooms_node.add_child(new_room)
	new_room.generate(STARTING_LOCATION, false)
	return new_room

func get_random_final_room(position: Vector2i) -> Room:
	var new_room := Room._new_room([position])
	_rooms_node.add_child(new_room)
	new_room.generate(position, true)
	return new_room

func get_boss_room(position: Vector2i) -> Room:
	return get_random_final_room(position)

func get_rooms_node() -> Node2D:
	return _rooms_node

func set_rooms_node(rooms_node: Node2D) -> void:
	_rooms_node = rooms_node
