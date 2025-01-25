extends Area2D
class_name UpgradeOnGround

var item: ItemData

func with_data(item: ItemData) -> void:
	self.item = item
	# $upgrade_sprite.texture = item.texture TODO Need to generate the sprites before we can do this.

func pick_up():
	Signals.upgrade_picked_up.emit(item)
	print("Picked up an upgrade!")
	queue_free()
