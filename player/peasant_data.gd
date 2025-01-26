extends Node

var shapePrefVal = []
var colourPrefVal = []
var shapePrefKey = []
var colourPrefKey = []

func _ready() -> void:
	for v in ItemData.Shape.values():
		shapePrefVal.append(v)
		shapePrefKey.append(ItemData.Shape.keys()[v])
	shapePrefVal.shuffle()
	
	for v in ItemData.Colour.values():
		colourPrefVal.append(v)
		colourPrefKey.append(ItemData.Colour.keys()[v])
	colourPrefVal.shuffle()
	
	print("Your peasants shape preferences: " + str(shapePrefKey))
	print("Your peasants colour preferences: " + str(colourPrefKey))

# this gotta be on click or some shit
func pick_upgrade(inventoryItems: Array[ItemData]):
	var topUpgrade: int
	var topUpgradeVal = 0
	
	# Uses array indexes as preference weight.
	for i in inventoryItems.size():
		var item = inventoryItems[i]
		#print("this item is: " + str(ItemData.Shape.keys()[item.shape]) + ", " + str(ItemData.Colour.keys()[item.colour]))
		var shapeVal = shapePrefVal.find(item.shape)
		var colourVal = colourPrefVal.find(item.colour)
	
		if shapeVal + colourVal > topUpgradeVal:
			topUpgrade = i
			topUpgradeVal = shapeVal + colourVal
	
	Signals.apply_upgrade.emit(inventoryItems[topUpgrade])
	return topUpgrade
