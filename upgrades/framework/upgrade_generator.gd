extends Node2D

@export var BASE_RARITY_WEIGHTS = [70, 25, 5]
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
			"positive": [10, 15],
			"negative": [-1, -5]
		},
		"move_speed": {
			"positive": [20, 30],
			"negative": [-5, -10]
		},
		"weapon_length": {
			"positive": [10, 15],
			"negative": [-1, -5]
		},
		"weapon_width": {
			"positive": [10, 15],
			"negative": [-1, -5]
		},
	},
	3: {
		"damage": {
			"positive": [15, 20],
			"negative": [-5, -7]
		},
		"move_speed": {
			"positive": [30, 40],
			"negative": [-10, -15]
		},
		"weapon_length": {
			"positive": [15, 20],
			"negative": [-5, -7]
		},
		"weapon_width": {
			"positive": [15, 20],
			"negative": [-5, -7]
		},
	},
}
@export var tier_two_items: Array[ItemData] = []
@export var tier_three_items: Array[ItemData] = []
@export var POSSIBLE_NAMES: Array[String] = ["Gem", "Diamond", "Pizza", "Rat of Justice", "Suspicious Herbs", "Heinz Tomato Soup", "One ounce jar of fermented chilli oil", "Bun Bo Hue", "remi from the hit animated pixar film ratatoullie"]
@export var POSSIBLE_TEXTURES: Array[Texture] = [preload("res://assets/crystals/base_crystal.png"), preload("res://assets/BasicSprites/bullet.png"), preload("res://assets/BasicSprites/heart.png"), preload("res://assets/BasicSprites/shotgun-shell.png")]

func _ready() -> void:
	tier_two_items = _load_all_upgrades_in_folder("upgrades/tier-2/")
	tier_three_items = _load_all_upgrades_in_folder("upgrades/tier-3/")

func generate_upgrade(rarity: int):
	var item: ItemData = _generate_upgrade_stats(rarity)
	item.colour = ItemData.Colour.values().pick_random()
	item.shape = ItemData.Shape.values().pick_random()
	
	if item.name == null:
		item.name = POSSIBLE_NAMES.pick_random() #todo: probably want names and textures to align aye
	
	if item.texture == null:
		item.texture = POSSIBLE_TEXTURES.pick_random() # TODO Align gem shape and colour to their texture
		
	return item
	

func _generate_upgrade_stats(rarity: int) -> ItemData:
	if rarity <= 0:
		rarity = _get_weighted_random(BASE_RARITY_WEIGHTS) + 1
	print(rarity)
	match rarity:
		1:
			return _generate_random_upgrade_stats(STAT_SCALES[1], [100, 50], [-1, 100])
		2:
			var upgrade_selected = randi_range(0, tier_two_items.size())
			if upgrade_selected == tier_two_items.size():
				return _generate_random_upgrade_stats(STAT_SCALES[2], [100, 100], [-1, 50])
			else:
				print("Selected %s tier 2 " % upgrade_selected)
				return tier_two_items[upgrade_selected]
		3:
			var upgrade_selected = randi_range(0, tier_three_items.size())
			if upgrade_selected == tier_three_items.size():
				return _generate_random_upgrade_stats(STAT_SCALES[3], [100, 100, 50], [-1, -1, 50])
			else:
				print("Selected %s tier 3 " % upgrade_selected)
				return tier_three_items[upgrade_selected]
			
	assert("Recieved an unknown rarity, this shouldnt happen.")
	return null
			
func _generate_random_upgrade_stats(stat_ranges, stat_count_chances, negative_stat_chance):
	var item: ItemData = ItemData.new()
	
	for i in len(stat_count_chances):
		if randi_range(0, 100) <= stat_count_chances[i]:
			var stat_selected = selected_random_stat(stat_ranges)
			var stat_direction = "negative" if randi_range(0, 100) <= negative_stat_chance[i] else "positive"
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
