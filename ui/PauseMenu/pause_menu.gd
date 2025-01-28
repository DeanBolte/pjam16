extends CanvasLayer

var close_sfx = preload("res://assets/sounds/ui/ui_close.wav")

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu/main_menu.tscn")

func _on_resume_button_pressed():
	handle_close()

func handle_close():
	%OpenCloseSfx.stream = close_sfx
	%OpenCloseSfx.play()
	self.visible = false
