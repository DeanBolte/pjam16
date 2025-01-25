extends Node2D

@export var BASE_RARITY_WEIGHTS = [0.70, 0.25, 0.05]
@export var STATS = ["damage", "move_speed", "weapon_length", "weapon_width"]
@export var STAT_SCALES = {
	1: {
		"damage": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"move_speed": {
			"positive": [10, 20],
			"negative": [-5, -10]
		},
		"weapon_length": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"weapon_width": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
	},
	2: {
		"damage": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"move_speed": {
			"positive": [10, 20],
			"negative": [-5, -10]
		},
		"weapon_length": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"weapon_width": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
	},
	3: {
		"damage": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"move_speed": {
			"positive": [10, 20],
			"negative": [-5, -10]
		},
		"weapon_length": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
		"weapon_width": {
			"positive": [5, 10],
			"negative": [-1, -5]
		},
	}
}
@export var TIER_TWO_ITEMS: Array[ItemData] = []
@export var TIER_THREE_ITEMS: Array[ItemData] = []

func generate_upgrade(rarity: int):
	var item: ItemData = _generate_upgrade_stats(rarity)
	item.colour = ItemData.Colour.values().pick_random()
	item.shape = ItemData.Shape.values().pick_random()
	
	return item
	

func _generate_upgrade_stats(rarity: int) -> ItemData:
	if rarity <= 0:
		rarity = _get_weighted_random(BASE_RARITY_WEIGHTS) + 1
	
	match rarity:
		1:
			return _generate_random_upgrade_stats(STAT_SCALES[1], [1, 0.5], [-1, 1])
		2:
			if randi_range(0, 1) < 0.5:
				return TIER_TWO_ITEMS[randi_range(0, TIER_TWO_ITEMS.size())]
			else:
				return _generate_random_upgrade_stats(STAT_SCALES[2], [1, 0.5], [-1, 0.5])
		[3, ..]:
			if randi_range(0, 1) < 0.7:
				return TIER_THREE_ITEMS[randi_range(0, TIER_TWO_ITEMS.size())]
			return _generate_random_upgrade_stats(STAT_SCALES[3], [1, 1, 0.5], [-1, -1, 0.5])
			
	assert("Recieved an unknown rarity, this shouldnt happen.")
	return null
			
func _generate_random_upgrade_stats(stat_ranges, stat_count_chances, negative_stat_chance):
	var item: ItemData = ItemData.new()
	
	for i in len(stat_count_chances):
		if randi_range(0, 1) <= stat_count_chances[i]:
			var stat_selected = selected_random_stat(stat_ranges)
			var stat_direction = "positive" if randi_range(0, 1) <= negative_stat_chance[i] else "negative"
			var stat_amount = select_random_stat_amount(stat_ranges, stat_selected, stat_direction)
			_modify_item(item, stat_selected, stat_amount)
	return item
			
func selected_random_stat(stat_ranges):
	return stat_ranges.keys()[randi() % stat_ranges.size()]
	
func select_random_stat_amount(stat_ranges, stat: String, direction: String):
	return randi_range(stat_ranges[stat][direction][0], stat_ranges[stat][direction][1])
			
func _modify_item(item: ItemData, stat_name: String, amount: int):
	match stat_name:
		"damage":
			item.damage += amount
		"move_speed":
			item.move_speed += amount
		"weapon_length":
			item.weapon_length += amount
		"weapon_width":
			item.weapon_width += amount

func _get_weighted_random(weights):
	var sum_of_weight = 0;
	for weight in weights:
		sum_of_weight += weight
		
	var rnd = randi_range(0, sum_of_weight);
	for i in len(weights):
		if rnd < weights[i]:
			return i
		rnd -= weights[i]
	
	return 0
	# TODO Fix this
	#assert(!"should never get here");
