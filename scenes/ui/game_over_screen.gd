extends "res://Scenes/ui/base_menu_panel.gd"

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/ui/game_menu.tscn")
	pass # Replace with function body.

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/levels/level_1.tscn")
	pass # Replace with function body.

func _on_grid_game_over():
	slide_in()
	pass # Replace with function body.
