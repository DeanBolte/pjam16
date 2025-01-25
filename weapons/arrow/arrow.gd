extends Node2D

# Base value that the instantiator can optionally modify directly
@export var damage: float = 5

# Base value that the instantiator can optionally modify
@export var speed: float = 25

# Instantiator should change this direction
@export var direction: Vector2 = Vector2.ZERO

# Default lifetime of an arrow, doesn't have to be modified, but can be.
@export var lifetime: float = 5

var velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * speed * delta
