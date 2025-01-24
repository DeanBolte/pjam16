extends CollisionShape2D
class_name Weapon

signal weapon_hit(object_hit: Area2D)

var weapon_starting_x = 0

func _ready() -> void:
	weapon_starting_x = position.x

func offset_weapon(offset: float) -> void:
	position.x = weapon_starting_x + offset

func get_weapon_tip() -> Vector2:
	return $weapon_tip.global_position
	
func increase_weapon_length(amount: float) -> void:
	pass
	
func increase_weapon_width(amount: float) -> void:
	pass
	
func decrease_weapon_length(amount: float) -> void:
	pass
	
func decrease_weapon_width(amount: float) -> void:
	pass
