extends Node2D

@export var BASE_RARITY_WEIGHTS = [70, 25, 5]
@export var ALL_STATS = ["DAMAGE", "MOVE_SPEED", "LENGTH", "WIDTH", "SWING_SPEED"]
@export var ATTRIBUTE_MAP = {
	"RED": "DAMAGE",
	"BLUE": "MOVE_SPEED",
	"YELLOW": "LENGTH",
	"ORANGE": "WIDTH",
	"GREEN": "SWING_SPEED",
	"PURPLE": "ALL_STATS",
	"PINK": "ALL_RANDOM",
	
	"CIRCLE": "MOVE_SPEED",
	"SQUARE": "SWING_SPEED",
	"TRIANGLE": "DAMAGE",
	"DIAMOND": "ALL_STATS"
}
@export var STAT_RANGES = {
	1: {
		"SHAPE_ALL_STATS": [2,3],
		"SHAPE_SINGLE_STAT": [3,5],
		"COLOUR_ALL_STATS": [3,5],
		"COLOUR_SINGLE_STAT": [5,10],
		"RANDOM_STAT": [5,6]
	},
	2: {
		"SHAPE_ALL_STATS": [6,8],
		"SHAPE_SINGLE_STAT": [8,10],
		"COLOUR_ALL_STATS": [8,10],
		"COLOUR_SINGLE_STAT": [10,20],
		"RANDOM_STAT": [10,11]
	},
	3: {
		"SHAPE_ALL_STATS": [16,18],
		"SHAPE_SINGLE_STAT": [18,20],
		"COLOUR_ALL_STATS": [18,20],
		"COLOUR_SINGLE_STAT": [20,30],
		"RANDOM_STAT": [20,21]
	}
}

@export var POSSIBLE_NAMES: Array[String] = ["Gem", "Diamond", "Pizza", "Rat of Justice", "Suspicious Herbs", "Heinz Tomato Soup", "One ounce jar of fermented chilli oil", "Bun Bo Hue", "remi from the hit animated pixar film ratatoullie"]


@export var tier_two_items: Array[ItemData] = []
@export var tier_three_items: Array[ItemData] = []
@export var gem_images = {}


func _ready() -> void:
	tier_two_items = _load_all_upgrades_in_folder("upgrades/tier-2/")
	tier_three_items = _load_all_upgrades_in_folder("upgrades/tier-3/")
	_load_all_upgrade_images()

func generate_upgrade(rarity: int) -> ItemData:
	if rarity <= 0:
		rarity = _get_weighted_random(BASE_RARITY_WEIGHTS) + 1
		
	match rarity:
		1:
			return _generate_random_item(1)
		2:
			var upgrade_selected = randi_range(0, tier_two_items.size())
			if upgrade_selected == tier_two_items.size():
				return _generate_random_item(rarity)
			else:
				return tier_two_items[upgrade_selected]
		3:
			var upgrade_selected = randi_range(0, tier_three_items.size())
			if upgrade_selected == tier_three_items.size():
				return _generate_random_item(rarity)
			else:
				return tier_three_items[upgrade_selected]

	assert("Shouldnt get here!")
	return null
	
	
func _generate_random_item(rarity: int) -> ItemData:
	var item: ItemData = ItemData.new()
	item.colour = ItemData.Colour.values().pick_random()
	item.shape = ItemData.Shape.values().pick_random()
	
	var colour_name = ItemData.Colour.keys()[item.colour]
	var shape_name = ItemData.Shape.keys()[item.shape]
	item.texture = gem_images[shape_name][colour_name]
	
	var colour_stat = ATTRIBUTE_MAP[colour_name]
	var shape_stat = ATTRIBUTE_MAP[shape_name]
	
	if colour_stat == "ALL_RANDOM":
		for i in 2:
			var random_stat = ALL_STATS.pick_random()
			var range = STAT_RANGES[rarity]["COLOUR_SINGLE_STAT"]
			var random_stat_amount = randi_range(range[0],range[1])
			_modify_item(item, random_stat, random_stat_amount)
	else:
		var range: Array 
		if shape_stat == "ALL_STATS":
			range = STAT_RANGES[rarity]["COLOUR_ALL_STATS"]
		else:
			range = STAT_RANGES[rarity]["COLOUR_SINGLE_STAT"]
		var colour_stat_amount = randi_range(range[0],range[1])
		_modify_item(item, colour_stat, colour_stat_amount)
		
	var range: Array
	if shape_stat == "ALL_STATS":
		range = STAT_RANGES[rarity]["SHAPE_ALL_STATS"]
	else:
		range = STAT_RANGES[rarity]["SHAPE_SINGLE_STAT"]
	var shape_stat_amount = randi_range(range[0],range[1])
	_modify_item(item, shape_stat, shape_stat_amount)
	
	return item
			
func _modify_item(item: ItemData, stat_name: String, amount: int):
	match stat_name:
		"DAMAGE":
			item.damage += amount
		"MOVE_SPEED":
			item.move_speed += amount
		"LENGTH":
			item.weapon_length += amount
		"WIDTH":
			item.weapon_width += amount
		"SWING_SPEED":
			item.swing_speed += amount
		"ALL_STATS":
			item.damage += amount
			item.move_speed += amount
			item.weapon_length += amount
			item.weapon_width += amount
			item.swing_speed += amount

func _get_weighted_random(weights):
	 # Calculate the total weight
	var total_weight = 0
	for weight in weights:
		total_weight += weight

	# Generate a random value between 0 and total_weight
	var random_value = randi() % total_weight

	# Find the corresponding weighted index
	var accumulated_weight = 0
	for i in range(weights.size()):
		accumulated_weight += weights[i]
		if random_value < accumulated_weight:
			return i

	assert(!"should never get here");
	return 0
	
func _load_all_upgrades_in_folder(folder: String) -> Array[ItemData]:
	var dir = DirAccess.open(folder)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	var upgrades: Array[ItemData] = []
	while file_name != "":
		var resource_to_load = "res://%s%s" % [folder, file_name]
		print("Loading %s" % resource_to_load)
		upgrades.append(load(resource_to_load))
		file_name = dir.get_next()
	return upgrades

func _load_all_upgrade_images():
	for shape in ItemData.Shape.keys():
		var shape_dict = {}
		for colour in ItemData.Colour.keys():
			var file_name = "res://assets/crystals/%s/%s_%s.png" % [shape.to_lower(), colour.to_lower(), shape.to_lower()]
			shape_dict[colour] = load(file_name)
		gem_images[shape] = shape_dict
