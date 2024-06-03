extends Node

signal create_goal

func _ready():
	create_goals()

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)

func _on_grid_check_goal(goal_type):
	check_goals(goal_type)

func create_goals():
	for i in get_child_count():
		var current = get_child(i)
		emit_signal("create_goal", current.max_needed, current.goal_texture, current.goal_string)
