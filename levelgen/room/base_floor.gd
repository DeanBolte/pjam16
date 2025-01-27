extends TileMapLayer

@export var TOP_LEFT_POSITION: Vector2i
@export var BOTTOM_RIGHT_POSITION: Vector2i
@export var MAX_TILES: int = 20

var tile_coords: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)]

func _ready() -> void:
	var tile_count = randi() % MAX_TILES
	for i in tile_count:
		tile_coords.shuffle()
		set_cell(_get_random_position(), 0, tile_coords.front())

func _get_random_position() -> Vector2i:
	var width := BOTTOM_RIGHT_POSITION.x - TOP_LEFT_POSITION.x
	var height := BOTTOM_RIGHT_POSITION.y - TOP_LEFT_POSITION.y

	return Vector2i(randi() % width, randi() % height) - Vector2i(width / 2, height / 2)
