extends Node2D

var ice_pieces = [];
var width = 8;
var height = 10;
var ice = preload ("res://Scenes/Ice.tscn")

# Goal signal
signal break_ice
@export var value: String

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array;

# Called when the node enters the scene tree for the first time.
func _ready():
	#ice_pieces = make_2d_array()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_grid_make_ice(board_position):
	#print("_on_grid_make_ice")
	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
	var current = ice.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 64, -board_position.y * 64 + 800)
	ice_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_ice(board_position):
	if ice_pieces.size() > 0:
		var ice_piece = ice_pieces[board_position.x][board_position.y]
		if ice_piece != null:
			ice_piece.take_damage(1)
			if ice_piece.health <= 0:
				ice_piece.queue_free()
				ice_pieces[board_position.x][board_position.y] = null
				emit_signal("break_ice", value)
