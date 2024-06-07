extends "res://Scenes/ui/base_menu_panel.gd"

signal play_pressed
signal settings_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	slide_in()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_1_pressed():
	emit_signal("play_pressed")

func _on_button_2_pressed():
	emit_signal("settings_pressed")
