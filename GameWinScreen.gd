extends "res://scripts/base_menu_panel.gd"




func _on_continue_button_pressed():
	get_tree().reload_current_scene()


func _on_goal_holder_game_win():
	slide_in()
