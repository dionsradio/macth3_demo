extends Node2D

# Grid Variables
@export var width: int;
@export var height: int;
@export var x_start: int;
@export var y_start: int;
@export var offset: int;

# piece scenes
var possible_pieces = [
	preload ("res://scenes/yellow_piece.tscn"),
	preload ("res://scenes/green_piece.tscn"),
	preload ("res://scenes/blue_piece.tscn"),
	preload ("res://scenes/light_green_piece.tscn"),
	preload ("res://scenes/pink_piece.tscn"),
	preload ("res://scenes/orange_piece.tscn"),
];

# generated pieces
var all_pieces = [];

# touch variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var controlling = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	touch_input();
	pass

# func match_at(column, row):
	# pass ;

# create a 2d array
func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

# create random color pieces
# NOTE: should add code to avoid match when first generated
func spawn_pieces():
	for i in width:
		for j in height:
			# choose a random number and store it
			var rand = floor(randf_range(0, possible_pieces.size()));
			var piece = possible_pieces[rand].instantiate(); # instance() func is no longer used;
			while (match_at(i, j, piece.color)):
				rand = floor(randf_range(0, possible_pieces.size()));
				piece = possible_pieces[rand].instantiate();
			add_child(piece);
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece;

# check match at specific location
func match_at(column, row, color):
	if column >= 2:
		if all_pieces[column - 1][row]&&all_pieces[column - 2][row]&&all_pieces[column - 1][row].color == color&&all_pieces[column - 2][row].color == color:
			return true;
	if row >= 2:
		if all_pieces[column][row - 1]&&all_pieces[column][row - 2]&&all_pieces[column][row - 1].color == color&&all_pieces[column][row - 2].color == color:
			return true;
	return false;

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + - offset * row;
	var pos = Vector2(new_x, new_y);
	return pos;

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / - offset);
	return Vector2(new_x, new_y);

func is_in_grid(column, row):
	if column >= 0&&column < width&&row >= 0&&row < height:
		return true;
	return false;

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position();
		var grid_position = pixel_to_grid(first_touch.x, first_touch.y);
		if is_in_grid(grid_position.x, grid_position.y):
			controlling = true;
		else:
			controlling = false;
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_global_mouse_position();
		var grid_position = pixel_to_grid(final_touch.x, final_touch.y);
		if is_in_grid(grid_position.x, grid_position.y)&&controlling:
			touch_difference(
				pixel_to_grid(first_touch.x, first_touch.y),
				pixel_to_grid(final_touch.x, final_touch.y)
			)
			controlling = false;
	pass ;

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row];
	var other_piece = all_pieces[column + direction.x][row + direction.y];
	all_pieces[column][row] = other_piece;
	all_pieces[column + direction.x][row + direction.y] = first_piece;
	# first_piece.position = grid_to_pixel(column + direction.x, row + direction.y);
	first_piece.move(grid_to_pixel(column + direction.x, row + direction.y));
	# other_piece.position = grid_to_pixel(column, row);
	other_piece.move(grid_to_pixel(column, row));

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0));
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2( - 1, 0));
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1));
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1));
	pass ;
