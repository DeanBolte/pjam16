extends Node

var ROOM_RESOURCE = preload("res://levelgen/room/room.tscn")


func _ready() -> void:
	var base_room: Room = ROOM_RESOURCE.instantiate()
	add_child(base_room)

	base_room.generate()
