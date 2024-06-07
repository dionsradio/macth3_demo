extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#Main Menu Panel active
	$MainMenu.slide_in()

func _on_main_menu_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/levels/Level1.tscn")

func _on_main_menu_settings_pressed():
	$SettingsMenu.slide_in()
	$MainMenu.slide_out()


func _on_settings_menu_back_button():
	$MainMenu.slide_in()
	$SettingsMenu.slide_out()


func _on_settings_menu_sound_change():
	pass # Replace with function body.
