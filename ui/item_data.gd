class_name ItemData extends Resource

enum Type { MAIN, SELECTED}
enum Colour { RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, PINK}
enum Shape { CIRCLE, SQUARE, TRIANGLE, DIAMOND}

@export var type: Type
@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

# Dummy stats, not final
@export var damage: int = 0
@export var move_speed: int  = 0
@export var weapon_length: int = 0
@export var weapon_width: int  = 0

@export var colour: Colour
@export var shape: Shape

@export var upgrade_behaviour: UpgradeBehaviour
