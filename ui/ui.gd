extends CanvasLayer

var open_sfx = preload("res://assets/sounds/ui/ui_open.wav")
var close_sfx = preload("res://assets/sounds/ui/ui_close.wav")

var open_icon = preload("res://assets/ui/chest-open.png")
var closed_icon = preload("res://assets/ui/chest.png")

@onready var VictoryPopup = $VictoryPopup
@onready var GameOverPopup = $GameOverPopup
@onready var PauseMenu = $PauseMenu
@onready var Inventory = $Inventory

enum Menus { NONE, INVENTORY, PAUSED }
var state: Menus = Menus.NONE

func _ready() -> void:
	Signals.health_updated.connect(_on_health_updated)
	Signals.boss_spawned.connect(_boss_spawned)
	Signals.boss_damage.connect(_boss_damage)

func _process(_delta: float) -> void:
	# Pause the game if either the pause menu or inventory is visible
	get_tree().paused = $VictoryPopup.visible or $GameOverPopup.visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if state == Menus.INVENTORY:
			_toggle_inventory(false)
		else:
			_toggle_pause_menu(state != Menus.PAUSED)
	elif event.is_action_pressed("inventory"):
		if state != Menus.PAUSED:
			_toggle_inventory(state != Menus.INVENTORY)

# Toggle the visibility of the inventory
func _toggle_inventory(open: bool) -> void:
	Inventory.visible = open
	if open:
		_open_menu(Menus.INVENTORY)
		%InventoryIcon.texture = open_icon
	else:
		_close_menu()
		%InventoryIcon.texture = closed_icon

# Toggle the visibility of the pause menu
func _toggle_pause_menu(open: bool) -> void:
	$PauseMenu.visible = open
	if open:
		_open_menu(Menus.PAUSED)
	else:
		_close_menu()

func _open_menu(state: Menus) -> void:
	self.state = state
	get_tree().paused = true
	SfxManager.stream = open_sfx
	SfxManager.play()

func _close_menu() -> void:
	get_tree().paused = false
	self.state = Menus.NONE
	SfxManager.stream = close_sfx
	SfxManager.play()


# Update and trigger the open/close sfx of the menus.
func trigger_sfx(node):
	$OpenCloseSfx.stream = close_sfx if node.visible else open_sfx
	$OpenCloseSfx.play()

func _on_health_updated(health: int):
	%HealthBar.value = health

func _boss_spawned(hp: int):
	$BossHealthBar.max_value = hp
	$BossHealthBar.value = hp
	$BossHealthBar.visible = true

func _boss_damage(damage: int):
	$BossHealthBar.value -= max(0, damage)
	if $BossHealthBar.value == 0:
		VictoryPopup.visible = true
