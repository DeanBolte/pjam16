extends CanvasLayer

var open_sfx = preload("res://audio/sfx/ui_open.wav")
var close_sfx = preload("res://audio/sfx/ui_close.wav")

func _ready():
	self.visible = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		handle_close() if self.visible else handle_open()

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_resume_button_pressed():
	handle_close()

func handle_open():
	%OpenCloseSfx.stream = open_sfx
	%OpenCloseSfx.play()
	self.visible = true

func handle_close():
	%OpenCloseSfx.stream = close_sfx
	%OpenCloseSfx.play()
	self.visible = false
