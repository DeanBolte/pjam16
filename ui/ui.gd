extends CanvasLayer

var open_sfx = preload("res://audio/sfx/ui_open.wav")
var close_sfx = preload("res://audio/sfx/ui_close.wav")

var open_icon = preload("res://assets/ui/chest-open.png")
var closed_icon = preload("res://assets/ui/chest.png")

func _ready():
	Signals.health_updated.connect(_on_health_updated)
	
	$GameOverPopup.visible = false
	$Inventory.visible = false
	$PauseMenu.visible = false

func _process(delta):
	# Pause the game if either the pause menu or inventory is visible
	get_tree().paused = $PauseMenu.visible or $Inventory.visible
	
	if Input.is_action_just_pressed("pause"):
		# Don't pause the game if the inventory is open.
		if $Inventory.visible:
			toggle_inventory()
		else:
			toggle_pause_menu()
	
	# Only toggle the inventory if the game isn't already paused.
	if Input.is_action_just_pressed("inventory") and not $PauseMenu.visible:
		toggle_inventory()

# Toggle the visibility of the inventory
func toggle_inventory():
	# Update icon based on current visibility state
	%InventoryIcon.texture = closed_icon if $Inventory.visible else open_icon
	trigger_sfx($Inventory)
	$Inventory.visible = not $Inventory.visible

# Toggle the visibility of the pause menu
func toggle_pause_menu():
	trigger_sfx($PauseMenu)
	$PauseMenu.visible = not $PauseMenu.visible

# Update and trigger the open/close sfx of the menus.
func trigger_sfx(node):
	$OpenCloseSfx.stream = close_sfx if node.visible else open_sfx
	$OpenCloseSfx.play()

func _on_health_updated(health: int):
	%HealthBar.value = health
