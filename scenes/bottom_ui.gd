extends TextureRect

signal pause_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pause_pressed():
	emit_signal("pause_game")
	get_tree().paused = true
