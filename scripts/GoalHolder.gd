extends Node

signal create_goal
signal game_win

func _ready():
	create_goals()

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)
	check_game_win()

func _on_grid_check_goal(goal_type):
	check_goals(goal_type)
	
func check_game_win():
	if goals_met():
		emit_signal("game_win")

func goals_met():
	for i in get_child_count():
		if !get_child(i).goal_met:
			return false
	return true

func create_goals():
	for i in get_child_count():
		var current = get_child(i)
		emit_signal("create_goal", current.max_needed, current.goal_texture, current.goal_string)


func _on_ice_holder_break_ice(goal_type):
	check_goals(goal_type)
