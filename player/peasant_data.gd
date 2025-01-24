extends Node

var shapePrefVal = []
var colourPrefVal = []
var shapePrefKey = []
var colourPrefKey = []

var peasants_items: Array[ItemData] = []

func _ready() -> void:
	Signals.select_upgrade.connect(_pickUpgrade)

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
func _pickUpgrade(inventoryItems: Array[ItemData]):
	var topUpgrade = null
	var topUpgradeVal = 0
	
	# Uses array indexes as preference weight.
	for item in inventoryItems:
		print("this item is: " + str(ItemData.Shape.keys()[item.shape]) + ", " + str(ItemData.Colour.keys()[item.colour]))
		var shapeVal = shapePrefVal.find(item.shape)
		var colourVal = colourPrefVal.find(item.colour)
	
		if shapeVal + colourVal > topUpgradeVal:
			topUpgrade = item
			topUpgradeVal = shapeVal + colourVal
			
	print("The item the peasant prefers: " + topUpgrade.name)
	peasants_items.append(topUpgrade)
	return topUpgrade
