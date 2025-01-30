extends AnimatedSprite2D

var slot_ranges = {
	0: [600, 688],
	1: [728, 816],
	2: [856, 944]
}
var target_position: Vector2
var target_slot: int

signal animation_done(slot: int)

func _ready() -> void:
	set_process(false)

func select_slot(slot: int):
	var viewport_size = get_viewport_rect().size
	var starting_x = randi_range(500, 1044)
	position = Vector2(starting_x, viewport_size.y + 100)
	
	var target_x = randi_range(slot_ranges[slot][0], slot_ranges[slot][1])
	var target_y = randi_range(212, 300)
	target_position = Vector2(target_x, target_y)
	target_slot = slot
	
	visible = true
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_direction = position.direction_to(target_position)
	position += target_direction * 300 * delta
	
	if position.distance_to(target_position) < 10:
		frame = 1
		set_process(false)
		$disapear_delay.start()
		animation_done.emit(target_slot)

func _on_disapear_delay_timeout() -> void:
	visible = false
	frame = 0
