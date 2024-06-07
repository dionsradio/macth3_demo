extends "res://Scenes/ui/base_menu_panel.gd"

func _ready():
	pass;

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/ui/GameMenu.tscn")

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/levels/Level1.tscn")

func _on_grid_game_over():
	slide_in()
