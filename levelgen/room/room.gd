extends Node2D
class_name Room

var CRATE_RESOURCE := preload("res://levelgen/room/objects/crate.tscn")

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
		var instance: Crate = CRATE_RESOURCE.instantiate()
		instance.position = _get_spawn_location()

		Objects.add_child(instance)


func _get_spawn_location() -> Vector2:
	return Vector2(randi() % SPAWN_AREA_WIDTH - SPAWN_AREA_WIDTH / 2, randi() % SPAWN_AREA_HEIGHT - SPAWN_AREA_HEIGHT / 2)

func _is_location_free() -> bool:
	return true


func generate(location: Vector2i) -> void:
	global_position = Vector2(location.x * ROOM_WIDTH , location.y * ROOM_HEIGHT)

	_generate_objects()

func close_doors() -> void:
	TopDoor.enabled = not _topDoorConnected
	BottomDoor.enabled = not _bottomDoorConnected
	RightDoor.enabled = not _rightDoorConnected
	LeftDoor.enabled = not _leftDoorConnected
