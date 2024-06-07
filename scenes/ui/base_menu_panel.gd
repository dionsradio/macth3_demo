extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func slide_in():
	$AnimationPlayer.play("slide/slide_in")
	
func slide_out():
	$AnimationPlayer.play_backwards("slide/slide_in")
