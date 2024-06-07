extends "res://Scenes/ui/base_menu_panel.gd"

signal sound_change
signal back_button

func _ready():
	pass;

func _on_button_1_pressed():
	emit_signal("sound_change")

func _on_button_2_pressed():
	emit_signal("back_button")
