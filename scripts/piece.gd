extends Node2D

# export(String) var color;
@export var color = ""
@export var row_texture: Texture
@export var column_texture: Texture
@export var adjacent_texture: Texture

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false

#var move_tween = null;
var timeout = 0.0;
var matched = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass ;
	#move_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#print("Node:", self, "created tween:", move_tween)

func move(target):
	var move_tween = create_tween();
	move_tween.set_trans(Tween.TRANS_ELASTIC)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", target, 0.8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass ;

func make_column_bomb():
	is_column_bomb = true
	$Sprite2D.texture = column_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func make_row_bomb():
	is_row_bomb = true
	$Sprite2D.texture = row_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)
	
func make_adjacent_bomb():
	is_adjacent_bomb = true
	$Sprite2D.texture = adjacent_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func dim():
	var sprite = get_node("Sprite2D");
	sprite.modulate = Color(1, 1, 1, .5);
	pass ;
