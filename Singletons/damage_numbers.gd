extends Node

const TWEEN_UP_DISTANCE = 50 # in px
const TWEEN_UP_DURATION = 0.15 # in seconds
const TWEEN_DOWN_DURATION = 0.5 # in seconds
const TWEEN_SCALE_DURATION = 0.25 # in seconds

const BASIC_COLOUR = "FFF"
const CRIT_COLOUR = "FFF200"
const OUTLINE_COLOUR = "000"

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.text = str(value) + ("!" if is_critical else "")
	number.z_index = 100
	number.label_settings = LabelSettings.new()
	
	var colour = CRIT_COLOUR if is_critical else BASIC_COLOUR
	number.label_settings.font_color = colour
	number.label_settings.font_size = 24
	number.label_settings.outline_color = OUTLINE_COLOUR
	number.label_settings.outline_size = 1
	
	# NOTE: This does not work. Not sure how to remove the CRT effects from the numbers...
	# Create a new CanvasItemMaterial to prevent CRT shader effects
	number.material = CanvasItemMaterial.new()
	number.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	# what the heck is a tween
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Go up by 25px in TWEEN_DURATION seconds
	tween.tween_property(
		number, "position:y", number.position.y - TWEEN_UP_DISTANCE, TWEEN_UP_DURATION
	).set_ease(Tween.EASE_OUT)
	
	# After TWEEN_UP_DURATION seconds, go back down to original position in TWEEN_DOWN_DURATION seconds
	tween.tween_property(
		number, "position:y", number.position.y, TWEEN_DOWN_DURATION
	).set_ease(Tween.EASE_IN).set_delay(TWEEN_UP_DURATION)
	
	# After TWEEN_DOWN_DURATION seconds, make number text scale to 0 (disappear) in TWEEN_SCALE_DURATION
	tween.tween_property(
		number, "scale", Vector2.ZERO, TWEEN_SCALE_DURATION
	).set_ease(Tween.EASE_IN).set_delay(TWEEN_DOWN_DURATION)
	
	await tween.finished
	number.queue_free()
