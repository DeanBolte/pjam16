extends Sprite2D

# Crossbow needs to pull back before being ready to shoot.
@export var is_ready := false

var ARROW_RESOURCE := preload("res://weapons/arrow/arrow.tscn")
var arrow_position_offset := Vector2(50, 0)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func pull_back() -> void:
	if is_ready:
		return
	$AnimationPlayer.play("pull_back")
	await $AnimationPlayer.animation_finished
	is_ready = true

func shoot(damage: float, direction: Vector2) -> void:
	if not is_ready:
		return
	is_ready = false

	var arrow = ARROW_RESOURCE.instantiate()
	arrow.global_position = global_position
	arrow.rotation = direction.angle()
	arrow.velocity = direction * arrow.speed
	arrow.damage = damage
	
	get_tree().current_scene.add_child(arrow)
