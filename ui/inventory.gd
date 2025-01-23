extends CanvasLayer

@onready var open_close_sfx = get_node("OpenCloseSfx")

@export var inventory_size := 10
@export var selected_size := 3

var open_sfx = preload("res://audio/sfx/ui_open.wav")
var open_icon = preload("res://assets/ui/chest-open.png")
var closed_icon = preload("res://assets/ui/chest.png")

var close_sfx = preload("res://audio/sfx/ui_close.wav")

var inv_items: Array[InventoryItem] = []
var selected_items: Array[InventoryItem] = []

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
		slot.init(ItemData.Type.MAIN, Vector2(64, 64))
		slot.update_inventory.connect(test)
		%Inv.add_child(slot)
	
	for i in selected_size:
		var selected_slot := InventorySlot.new()
		selected_slot.init(ItemData.Type.MAIN, Vector2(96, 96))	
		selected_slot.update_inventory.connect(test)
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
			%InventoryIcon.texture = closed_icon
		else:
			open_close_sfx.stream = open_sfx
			%InventoryIcon.texture = open_icon
		open_close_sfx.play()
		self.visible = !self.visible
	
	# Enable the button when all SelectedItems slots are filled.
	%SelectButton.disabled = !%SelectedItems.get_children().all(func(child): return child.get_child_count() > 0)
	
func test():
	#for i in %Inv.get_child_count() - 1:
		#print("%s: %s" % [i, %Inv.get_child(i).get_child_count()])
	print("a")
