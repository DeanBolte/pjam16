extends CanvasLayer
@export var inventory_size := 9
@export var selected_size := 3

var upgrade_selected_sfx = preload("res://assets/sounds/ui/upgrade_selected.wav")
var open_sfx = preload("res://assets/sounds/ui/ui_open.wav")
var open_icon = preload("res://assets/ui/chest-open.png")
var closed_icon = preload("res://assets/ui/chest.png")
var close_sfx = preload("res://assets/sounds/ui/ui_close.wav")

const SELECT_UPGRADE_SOUNDS = [
	preload("res://assets/sounds/player/upgrade_select/cant_go_wrong.wav"),
	preload("res://assets/sounds/player/upgrade_select/i_like_this_one.wav"),
	preload("res://assets/sounds/player/upgrade_select/I_think_we_need_this_one.wav"),
	preload("res://assets/sounds/player/upgrade_select/ooo_shiny.wav"),
	preload("res://assets/sounds/player/upgrade_select/this_one_looks_neat.wav")
]

var inv_items: Array[ItemData] = []
var selected_items: Array[ItemData] = []

func _ready():
	Signals.upgrade_picked_up.connect(add_item_to_inv)

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
	
	calculate_inv_count()

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
	update_upgrade_button()

func _on_select_button_pressed() -> void:
	var selected_upgrade_slot = PeasantData.pick_upgrade(selected_items)
	var random_sfx = SELECT_UPGRADE_SOUNDS.pick_random()
	%SelectButton.disabled = true
	$VoiceLineSfxManager.stream = random_sfx
	$VoiceLineSfxManager.play()
	$peasant_cursor.select_slot(selected_upgrade_slot)


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

func _on_peasant_cursor_animation_done() -> void:
	for i in selected_items.size():
		for n in %SelectedItems.get_child(i).get_children():
			n.free()
	
	$DropSfx.stream = upgrade_selected_sfx
	$DropSfx.play()
	
	selected_items.clear()
	update_upgrade_button()
