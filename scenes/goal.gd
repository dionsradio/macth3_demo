extends Node

# Goal information
@export var goal_texture: Texture
@export var max_needed: int
@export var goal_string: String
var goal_met = false

var number_collected = 0

func check_goal(goal_type):
	if goal_type == goal_string:
		update_goal()
	pass
	
func update_goal():
	if number_collected < max_needed:
		number_collected += 1
	if number_collected == max_needed:
		if !goal_met:
			goal_met = true
