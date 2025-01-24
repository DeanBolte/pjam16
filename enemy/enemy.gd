extends CharacterBody2D

@export var speed: int = 10000
@export var health: int = 3
@export var invincibility_time: float = 2 # seconds of invincibility after being hit

var random_direction: Vector2 = Vector2.ZERO
var is_invincible: bool = false

func _ready():
	$invincibility_timer.wait_time = invincibility_time
	$invincibility_timer.one_shot = true
	set_random_direction()

func _process(delta):
	patrol(delta)

func patrol(delta):
	velocity = random_direction * speed * delta
	move_and_slide()

	if should_change_direction():
		set_random_direction()

func set_random_direction():
	random_direction = Vector2(
		randi() % 3 - 1,  # -1, 0, or 1 for x-axis
		randi() % 3 - 1   # -1, 0, or 1 for y-axis
	).normalized()

	if random_direction == Vector2.ZERO:
		set_random_direction()

# 1% chance that per frame, the enemy will decide to change direction
func should_change_direction() -> bool:
	return randi() % 100 < 1

func on_hit():
	if is_invincible:
		return
	take_damage(1)

func take_damage(amount: int):
	health -= amount
	$hit_sound.play()
	print("Enemy took ", amount, " dmg")
	if health <= 0:
		die()
	else:
		start_invincibility()

func die():
	print("Enemy defeated!")
	queue_free()

func start_invincibility():
	if not is_invincible:
		is_invincible = true
		$invincibility_timer.start()
		$invincibility_timer.timeout.connect(Callable(self, "end_invincibility"))

		# We don't have to show vulnerability this way - we can do other ways. This shade of white is just obvious for now.
		# Slightly white shade to show invincibility
		$sprite.modulate = Color(1, 1, 1, 0.5)

func end_invincibility():
	is_invincible = false
	$sprite.modulate = Color(1, 1, 1, 1)
