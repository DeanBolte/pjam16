extends Area2D
class_name UpgradeOnGround

var item: ItemData

func _ready(): 
	Signals.upgrade_picked_up_post.connect(remove_from_ground)

func with_data(item: ItemData) -> void:
	self.item = item
	$upgrade_sprite.texture = item.texture

func pick_up():
	Signals.upgrade_picked_up.emit(item)
	print("Picked up an upgrade!")
	
func remove_from_ground(_item):
	if item == _item:
		queue_free()


func _on_init_spawn_delay_timeout() -> void:
	monitorable = true
