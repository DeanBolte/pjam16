extends Area2D
class_name UpgradeOnGround

var item: ItemData

@onready var sfx_manager = get_node("../../../SfxManager")
@onready var pickup_sfx = preload("res://audio/sfx/item_pickup.wav")

func _ready(): 
	Signals.upgrade_picked_up_post.connect(remove_from_ground)

func with_data(item: ItemData) -> void:
	self.item = item
	$upgrade_sprite.texture = item.texture

func pick_up():
	Signals.upgrade_picked_up.emit(item)
	sfx_manager.stream = pickup_sfx
	sfx_manager.play()
	
func remove_from_ground(_item):
	if item == _item:
		queue_free()

func _on_init_spawn_delay_timeout() -> void:
	monitorable = true
