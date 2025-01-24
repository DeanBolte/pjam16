extends CanvasLayer

@onready var open_close_sfx = get_node("OpenCloseSfx")

@export var inventory_size := 9
@export var selected_size := 3

var open_sfx = preload("res://audio/sfx/ui_open.wav")
var open_icon = preload("res://assets/ui/chest-open.png")
var closed_icon = preload("res://assets/ui/chest.png")

var close_sfx = preload("res://audio/sfx/ui_close.wav")

var inv_items: Array[ItemData] = []
var selected_items: Array[ItemData] = []

# Dummy items for initial load, remove these once ready.
var items_load = [
	"res://ui/development/sword.tres",
	"res://ui/development/emerald.tres"
]
var selected_items_load = [
	"res://ui/development/diamond.tres",
	"res://ui/development/basic_crystal.tres"
]

func _ready():
	self.visible = false
	
	for i in inventory_size:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(96, 96))
		slot.update_inventory.connect(move_item)
		%Inv.add_child(slot)
	
	for i in selected_size:
		var selected_slot := InventorySlot.new()
		selected_slot.init(ItemData.Type.SELECTED, Vector2(128, 128))	
		selected_slot.update_inventory.connect(move_item)
		%SelectedItems.add_child(selected_slot)
	
	for i in items_load.size():
		var item := InventoryItem.new()
		item.init(load(items_load[i]))
		item.data.type = ItemData.Type.MAIN
		inv_items.append(item.data)
		%Inv.get_child(i).add_child(item)
	
	for i in selected_items_load.size():
		var selected_item := InventoryItem.new()
		selected_item.init(load(selected_items_load[i]))
		selected_item.data.type = ItemData.Type.SELECTED
		selected_items.append(selected_item.data)
		%SelectedItems.get_child(i).add_child(selected_item)

func _process(delta):
	if Input.is_action_just_pressed("inventory"):		
		if self.visible:
			open_close_sfx.stream = close_sfx
			%InventoryIcon.texture = closed_icon
		else:
			open_close_sfx.stream = open_sfx
			%InventoryIcon.texture = open_icon
		open_close_sfx.play()
		self.visible = !self.visible
	
	# Enable the button when all SelectedItems slots are filled.
	%SelectButton.disabled = !%SelectedItems.get_children().all(func(child): return child.get_child_count() > 0)
	
func move_item(item, newType):
	if (item.type == newType):
		return
		
	if (item.type == ItemData.Type.SELECTED): 
		inv_items.append(item)
		selected_items.erase(item)
	else:
		selected_items.append(item)
		inv_items.erase(item)
	item.type = newType	

func _on_select_button_pressed() -> void:
	Signals.select_upgrade.emit(selected_items)
	for i in selected_items.size():
		for n in %SelectedItems.get_child(i).get_children():
			n.free()
	
	selected_items.clear()
	# remove the selected one from the loot pool
