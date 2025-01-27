extends Area2D


func _on_area_entered(object_hit: Area2D) -> void:
	if (object_hit.has_method("process_hit")):
		var damage = get_parent().damage
		object_hit.process_hit(damage, self, false)
		queue_free()
