extends Node

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)


func _on_grid_check_goal(goal_type):
	print("_on_grid_check_goal", goal_type)
	check_goals(goal_type)
