extends Weapon
	
func change_weapon_width(amount: float):
	scale.x += (amount / 20)
	$sword_hilt.scale.x = 1 / scale.x
	
func change_weapon_length(amount: float):
	var newScale = scale.y + (amount / 20)
	
	var old_height = $sword_sprite.texture.get_width() * scale.y 
	var new_height = $sword_sprite.texture.get_width() * newScale 
	var pixel_difference = (new_height - old_height) / 2

	weapon_starting_x += pixel_difference
	scale.y = newScale

func _on_sword_edge_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var body_shape2d: Shape2D = area.shape_owner_get_shape(area_shape_index, 0)
	var area_shape2d: Shape2D = $sword_edge_hitbox.shape_owner_get_shape(local_shape_index, 0)
	
	var body_shape2d_transform = area.shape_owner_get_owner(local_shape_index).get_global_transform()
	var area_shape2d_transform = $sword_edge_hitbox.shape_owner_get_owner(area_shape_index).get_global_transform()
	
	var collision_points = area_shape2d.collide_and_get_contacts(area_shape2d_transform, body_shape2d, body_shape2d_transform)
	
	var collision_sum = Vector2(0, 0)
	for point in collision_points:
		collision_sum += point
	var average_collision_point = collision_sum / collision_points.size()
	weapon_hit.emit(area, average_collision_point)
	
