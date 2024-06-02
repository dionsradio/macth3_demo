extends TextureRect

@onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel
var current_score = 0

@onready var counter_label = $MarginContainer/HBoxContainer/CounterLabel
var current_count = 0

@onready var score_bar = $MarginContainer/HBoxContainer/VBoxContainer/TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	update_score_bar()
	score_label.text = str(current_score)

func _on_grid_update_counter(amount_to_change = -1):
	current_count += amount_to_change
	counter_label.text = str(current_count)

func setup_score_bar(max_score):
	score_bar.max_value = max_score

func update_score_bar():
	score_bar.value = current_score


func _on_grid_setup_max_score(max_score):
	setup_score_bar(max_score)
	pass # Replace with function body.
