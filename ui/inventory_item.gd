class_name InventoryItem extends TextureRect

@export var data: ItemData

func init(d: ItemData) -> void:
	data = d

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	tooltip_text = "%s\n%s\n" % [data.name, data.description]
	
	if data.damage != 0:
		tooltip_text += "\n%s%d damage" % ["+" if data.damage > 0 else "", data.damage]
	if data.move_speed != 0:
		tooltip_text += "\n%s%d move speed" % ["+" if data.move_speed > 0 else "", data.move_speed]
	if data.range != 0:
		tooltip_text += "\n%s%d range" % ["+" if data.range > 0 else "", data.range]


func _get_drag_data(at_position: Vector2):
	set_drag_preview(make_drag_preview(at_position))
	return self
	
func make_drag_preview(at_position: Vector2):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)
	
	var c := Control.new()
	c.add_child(t)
	
	return c
