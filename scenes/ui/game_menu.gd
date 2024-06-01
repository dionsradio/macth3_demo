extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#Main Menu Panel active
	$Main.slide_in()



func _on_main_play_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	pass # Replace with function body.


func _on_main_settings_pressed():
	$Settings.slide_in()
	$Main.slide_out()
	pass # Replace with function body.



func _on_settings_back_button():
	$Main.slide_in()
	$Settings.slide_out()
	pass # Replace with function body.


func _on_settings_sound_change():
	pass # Replace with function body.
