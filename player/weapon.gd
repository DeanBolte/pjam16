extends CollisionShape2D
class_name Weapon

signal weapon_hit(object_hit: Area2D, collision_point: Vector2)

var weapon_starting_x = 0

func _ready() -> void:
	weapon_starting_x = position.x
	GlobalReferences.weapon_reference = self

func offset_weapon(offset: float) -> void:
	position.x = weapon_starting_x + offset

func get_weapon_tip() -> Vector2:
	return $weapon_tip.global_position
	
func change_weapon_width(amount: float) -> void:
	pass
	
func change_weapon_length(amount: float) -> void:
	pass
