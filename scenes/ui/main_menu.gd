extends "res://Scenes/ui/base_menu_panel.gd"

signal play_pressed
signal settings_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_button_1_pressed():
	emit_signal("play_pressed")

func _on_button_2_pressed():
	emit_signal("settings_pressed")
