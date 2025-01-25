extends Weapon
	
func change_weapon_width(amount: float):
	scale.x += amount
	$sword_hilt.scale.x = 1 / scale.x
	
func change_weapon_length(amount: float):
	var newScale = scale.y + amount
	
	var old_height = $sword_sprite.texture.get_width() * scale.y 
	var new_height = $sword_sprite.texture.get_width() * newScale 
	var pixel_difference = (new_height - old_height) / 2

	weapon_starting_x += pixel_difference
	scale.y = newScale
	
	
func _on_weapon_edge_hitbox_area_entered(area: Area2D) -> void:
	weapon_hit.emit(area)
