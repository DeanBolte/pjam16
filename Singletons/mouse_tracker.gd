extends Node

# Configuration
const TRACKING_DURATION: float = 0.25  # Time duration to track mouse speed (in seconds)
const MAX_SWIPE_SPEED: float = 1000.0  # Max speed (for scaling damage or effects)
const MAX_SPEED_HISTORY_SIZE: int = 4

# Internal state
var last_position: Vector2
var speed_history: Array = []  # Stores speed history for the given duration
var time_elapsed: float = 0.0  # Tracks time elapsed during the swipe tracking

# Called every frame
func _process(delta: float) -> void:
	# Update elapsed time
	time_elapsed += delta
	
	var current_position = get_viewport().get_mouse_position()
	
	# Calculate the speed (distance traveled between frames)
	var speed = current_position.distance_to(last_position) / delta
	last_position = current_position
	
	# Append speed to history after each tracking_duration seconds
	if time_elapsed >= TRACKING_DURATION:
		speed_history.append(speed)
		time_elapsed = 0.0
	
	if (speed_history.size() > MAX_SPEED_HISTORY_SIZE):
		speed_history.pop_front()

# Returns the average swipe speed within the tracking duration
func get_swipe_speed() -> float:
	if speed_history.size() == 0:
		return 0.0

	# Return the average swipe speed
	var total_speed = 0.0
	for speed in speed_history:
		total_speed += speed

	return total_speed / speed_history.size()

# Reset the tracking data (optional, for re-calibration)
func reset_tracking():
	speed_history.clear()
	last_position = get_viewport().get_mouse_position()
	time_elapsed = 0.0
