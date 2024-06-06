extends "res://scripts/base_menu_panel.gd"

func _on_quit_pressed():
	get_tree().quit()

func _on_continue_pressed():
	get_tree().paused = false
	slide_out()

func _on_bottom_ui_pause_game():
	slide_in()
