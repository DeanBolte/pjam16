extends Sprite2D

# Base value that the instantiator can optionally modify directly
@export var damage: float = 20

# Base value that the instantiator can optionally modify
@export var speed: float = 200

# Instantiator should change this direction
@export var direction: Vector2 = Vector2.ZERO

# Default lifetime of an arrow, doesn't have to be modified, but can be.
@export var lifetime: float = 5

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_sword_edge_hitbox_area_entered(object_hit: Area2D) -> void:
	if (object_hit.has_method("process_hit")):
		object_hit.process_hit(damage, self, false)
		queue_free()
