extends TextureRect

var current_number = 0
var max_value = 0
var goal_string = ""
var goal_texture
@onready var goal_label = $HBoxContainer/VBoxContainer/Label
@onready var this_texture = $HBoxContainer/VBoxContainer/TextureRect

func set_goal_values(new_max, new_texture, new_string):
	this_texture.texture = new_texture
	max_value = new_max
	goal_string = new_string
	goal_label.text = str(current_number) + "/" + str(max_value)

func update_goal_values(goal_type):
	# print("update_goal_values:", goal_type)
	if goal_string == goal_type:
		current_number += 1;
		if current_number <= max_value:
			goal_label.text = str(current_number) + "/" + str(max_value)
