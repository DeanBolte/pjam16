extends Label

var elapsed_time := 0.0  # Total time in seconds

func _process(delta: float) -> void:
	# Stop updating when the game is paused
	if get_tree().paused:
		return 
	
	elapsed_time += delta
	update_timer_text()

func update_timer_text() -> void:
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)

	text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
