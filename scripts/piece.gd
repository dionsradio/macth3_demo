extends Node2D

# export(String) var color;

@export var color = "";
var move_tween = null;
var timeout = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = create_tween();
	print("Node:",self, "created tween:", move_tween)

func move(target):
	print(self)
	print("Current Position:", position)
	print("Target Position:", target)
	move_tween.set_trans(Tween.TRANS_ELASTIC)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", target, 0.3)

	print("Curnret Position:", position);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
