extends Control

@export var inventory_size := 10
@export var selected_size := 3

signal update_count

var items_load = [
	"res://ui/development/sword.tres",
	"res://ui/development/emerald.tres"
]

var selected_items_load = [
	"res://ui/development/diamond.tres"
]

func _ready():
	self.visible = false
	
	for i in inventory_size:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(64, 64))
		%Inv.add_child(slot)
	
	for i in selected_size:
		var selected_slot := InventorySlot.new()
		selected_slot.init(ItemData.Type.MAIN, Vector2(96, 96))	
		%SelectedItems.add_child(selected_slot)
	
	for i in items_load.size():
		var item := InventoryItem.new()
		item.init(load(items_load[i]))
		%Inv.get_child(i).add_child(item)
	
	for i in selected_items_load.size():
		var selected_item := InventoryItem.new()
		selected_item.init(load(selected_items_load[i]))
		%SelectedItems.get_child(i).add_child(selected_item)
	
	%InvCount.text = "%s/%s" % [items_load.size(), inventory_size]

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		self.visible = !self.visible
