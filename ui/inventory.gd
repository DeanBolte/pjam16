extends Control

@onready var open_close_sfx = get_node("/root/Inventory/OpenCloseSfx")

@export var inventory_size := 10
@export var selected_size := 3

var open_sfx = preload("res://assets/sfx/ui_open.wav")
var close_sfx = preload("res://assets/sfx/ui_close.wav")

var inv_items: Array[InventoryItem] = []
var selected_items: Array[InventoryItem] = []

# Dummy items for initial load, remove these once ready.
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

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if self.visible:
			open_close_sfx.stream = close_sfx
		else:
			open_close_sfx.stream = open_sfx
		open_close_sfx.play()
		self.visible = !self.visible
	
	# Enable the button when all SelectedItems slots are filled.
	%SelectButton.disabled = !%SelectedItems.get_children().all(func(child): return child.get_child_count() > 0)
