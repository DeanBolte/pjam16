class_name InventorySlot extends PanelContainer

@export var type: ItemData.Type
@onready var drop_sfx = get_node("../../DropSfx")

func init(t: ItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position: Vector2, data: Variant):
	if data is InventoryItem:
		if type == ItemData.Type.MAIN:
			if get_child_count() == 0:
				return true
			else:
				if type == data.get_parent().type:
					return true
			return get_child(0).data.type == data.data.type
		else:
			return data.data.type == type

func _drop_data(at_position: Vector2, data: Variant):
	if get_child_count() > 0:
		var item := get_child(0)
		if item == data:
			return
		item.reparent(data.get_parent())
	drop_sfx.play()
	data.reparent(self)
