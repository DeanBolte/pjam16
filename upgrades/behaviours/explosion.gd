extends AnimatedSprite2D

var is_detecting = true
var detected_something = false

func _ready() -> void:
	play()

func _on_animation_finished() -> void:
	queue_free()

func _process(delta):
	if detected_something:
		is_detecting = false
		$explosion_hitbox/explosion_hitbox_shape.disabled = true
		$explosion_hitbox.monitorable = false
		$explosion_hitbox.monitoring = false

func _on_explosion_hitbox_area_entered(area: Area2D) -> void:
	if is_detecting:
		if area.has_method("process_hit"):
			area.process_hit(30, self, true)
		detected_something = true
