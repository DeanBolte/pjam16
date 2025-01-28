extends CanvasLayer

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/deans_garden.tscn")

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu/main_menu.tscn")
