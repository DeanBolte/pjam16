extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.apply_upgrade.connect(_apply_upgrade)

func _apply_upgrade(upgrade: ItemData):
	if upgrade.upgrade_behaviour != null:
		var behaviour_node = load(upgrade.upgrade_behaviour.behaviour_node)
		add_child(behaviour_node.instantiate())
