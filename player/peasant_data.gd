extends Node

var shapePrefArr = []
var colourPrefArr = []

func _ready() -> void:
	for key in ItemData.Shape.keys():
		shapePrefArr.append(key)
	shapePrefArr.shuffle()
	
	for key in ItemData.Colour.keys():
		colourPrefArr.append(key)
	colourPrefArr.shuffle()

# this gotta be on click or some shit
func pickUpgrade(itemDatas: Array[ItemData]):
	var topUpgrade = null
	var topUpgradeVal = 0
	
	# Uses array indexes as preference weight.
	for item in itemDatas:
		var shapeVal = itemDatas.find(item.shape)
		var colourVal = itemDatas.find(item.colour)
	
		if shapeVal + colourVal > topUpgrade:
			topUpgrade = item
			topUpgradeVal = shapeVal + colourVal
			
	return topUpgrade
