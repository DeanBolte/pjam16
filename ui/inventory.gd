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
	"res://upgrades/tier-2/sword.tres",
	"res://upgrades/tier-3/emerald.tres"
]
var selected_items_load = [
	"res://upgrades/tier-3/diamond.tres",
	"res://upgrades/tier-2/basic_crystal.tres"
]

func _ready():
	Signals.upgrade_picked_up.connect(add_item_to_inv)
	Signals.health_updated.connect(_on_health_updated)
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
	
	# TODO: Remove these once the game is ready! These are solely for testing!!!
	for i in items_load.size():
		var item := InventoryItem.new()
		var test = load(items_load[i])
		item.init(test)
		item.data.type = ItemData.Type.MAIN
		inv_items.append(item.data)
		%Inv.get_child(i).add_child(item)
	
	for i in selected_items_load.size():
		var selected_item := InventoryItem.new()
		selected_item.init(load(selected_items_load[i]))
		selected_item.data.type = ItemData.Type.SELECTED
		selected_items.append(selected_item.data)
		%SelectedItems.get_child(i).add_child(selected_item)

	calculate_inv_count()

func _process(delta):
	if Input.is_action_just_pressed("inventory"):		
		open_close_sfx.stream = close_sfx if self.visible else open_sfx
		%InventoryIcon.texture = closed_icon if self.visible else open_icon

		open_close_sfx.play()
		self.visible = !self.visible

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
	calculate_inv_count()

	# Enable the button when all SelectedItems slots are filled.
	update_upgrade_button()

func _on_select_button_pressed() -> void:
	Signals.select_upgrade.emit(selected_items)
	for i in selected_items.size():
		for n in %SelectedItems.get_child(i).get_children():
			n.free()
	
	selected_items.clear()
	update_upgrade_button()
	# remove the selected one from the loot pool

func add_item_to_inv(item: ItemData):
	for node in %Inv.get_children(): 
		if node.get_child_count() == 0:
			var invenItem := InventoryItem.new()
			invenItem.init(item)
			invenItem.data.type = ItemData.Type.MAIN
			inv_items.append(item)
			
			node.add_child(invenItem)
			Signals.upgrade_picked_up_post.emit(item)
			calculate_inv_count()
			break
	

# Enable the button when all SelectedItems slots are filled.
func update_upgrade_button():
	%SelectButton.disabled = selected_items.size() != selected_size

func calculate_inv_count():
	%InventoryCount.text = "%s/%s" % [inv_items.size(), inventory_size]

func _on_health_updated(health: int):
	%HealthBar.value = health
