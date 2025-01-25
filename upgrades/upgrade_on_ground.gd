extends Area2D
class_name UpgradeOnGround

var item: ItemData

func with_data(item: ItemData) -> void:
	self.item = item
	$upgrade_sprite.texture = item.texture

func pick_up():
	Signals.upgrade_picked_up.emit(item)
	print("Picked up an upgrade!")
	queue_free()
	
