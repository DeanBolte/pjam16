extends CharacterBody2D

@export var speed: int = 10000
@export var health: int = 3

var randomDirection: Vector2 = Vector2.ZERO

func _ready():
	set_random_direction()

func _process(delta):
	patrol(delta)

func patrol(delta):
	velocity = randomDirection * speed * delta
	move_and_slide()

	if should_change_direction():
		set_random_direction()

func set_random_direction():
	randomDirection = Vector2(
		randi() % 3 - 1,  # -1, 0, or 1 for x-axis
		randi() % 3 - 1   # -1, 0, or 1 for y-axis
	).normalized()

	if randomDirection == Vector2.ZERO:
		set_random_direction()

# 1% chance that per frame, the enemy will decide to change direction
func should_change_direction() -> bool:
	return randi() % 100 < 1

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	print("Enemy defeated!")
	queue_free()
