extends Control

# Ensure whenever the main menu loads, the game is not paused.
func _ready():
	get_tree().paused = false

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/deans_garden.tscn")


func _on_tutorial_button_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu/tutorial_menu.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu/credits_menu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
