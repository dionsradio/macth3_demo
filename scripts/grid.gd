extends Node2D

enum {wait, move}
var state

# Grid Variables
@export var width: int;
@export var height: int;
@export var x_start: int;
@export var y_start: int;
@export var offset: int;
@export var y_offset: int;

# Obstacle Stuff
@export var empty_spaces: PackedVector2Array;

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

# Swap Back Variables;
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)

# touch variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var controlling = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move;
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print("state: ", state);
	if state == move:
		touch_input()

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

func restricted_movement(place):
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true;
	return false;

# create random color pieces
# NOTE: should add code to avoid match when first generated
func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_movement(Vector2(i, j)):
				# choose a random number and store it
				var rand = floor(randf_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instantiate(); # instance() func is no longer used;
				while (match_at(i, j, piece.color)):
					rand = floor(randf_range(0, possible_pieces.size()));
					piece = possible_pieces[rand].instantiate();
				piece.position = grid_to_pixel(i, j)
				all_pieces[i][j] = piece;
				add_child(piece);

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

func is_in_grid(grid_position):
	if grid_position.x >= 0&&grid_position.x < width&&grid_position.y >= 0&&grid_position.y < height:
		return true;
	return false;

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			controlling = true;
	
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			controlling = false;
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			touch_difference(first_touch, final_touch);
	pass ;

func swap_pieces(column, row, direction, _find_matched=true):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][row + direction.y] = first_piece
	if first_piece != null&&other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction)
		state = wait
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		if _find_matched:
			find_matches()
		else:
			state = move;

func store_info(last_piece, other_piece, place, direction):
	piece_one = last_piece;
	piece_two = other_piece;
	last_place = place;
	last_direction = direction;

func swap_back():
	# move the previois swapped pieces back to the previois places.
	if piece_one != null&&piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction, false)
	state = move

func collapse_columns():
	# var collapsed = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] == null&&!restricted_movement(Vector2(i, j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						# collapsed = true;
						break
	# if collapsed == true:
		get_parent().get_node("refill_timer").start();

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

func find_matches():
	var matched = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				var current_piece = all_pieces[i][j]
				if i > 0&&i < width - 1:
					var left_piece = all_pieces[i - 1][j];
					var right_piece = all_pieces[i + 1][j];
					if left_piece != null&&right_piece != null:
							if left_piece.color == current_color&&right_piece.color == current_color:
								current_piece.matched = true
								current_piece.dim()
								left_piece.matched = true
								left_piece.dim()
								right_piece.matched = true
								right_piece.dim()
								matched = true
				if j > 0&&j < height - 1:
					var top_piece = all_pieces[i][j - 1];
					var bottom_piece = all_pieces[i][j + 1];
					if top_piece != null&&bottom_piece != null:
							if top_piece.color == current_color&&bottom_piece.color == current_color:
								current_piece.matched = true
								current_piece.dim()
								top_piece.matched = true
								top_piece.dim()
								bottom_piece.matched = true
								bottom_piece.dim()
								matched = true
	if matched == true:
		get_parent().get_node("destroy_timer").start();
	else:
		swap_back();

# find and destroy matched pieces
func destroy_matched():
	var destroyed = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					destroyed = true;
					all_pieces[i][j].queue_free();
					all_pieces[i][j] = null;
	if destroyed == true:
		get_parent().get_node("collapse_timer").start();

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null&&!restricted_movement(Vector2(i, j)):
				var rand = floor(randf_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instantiate(); # instance() func is no longer used;
				while (match_at(i, j, piece.color)):
					rand = floor(randf_range(0, possible_pieces.size()));
					piece = possible_pieces[rand].instantiate();
				add_child(piece);
				piece.position = grid_to_pixel(i, j + y_offset)
				piece.move(grid_to_pixel(i, j));
				all_pieces[i][j] = piece;
	# find_matches()
	after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches();
					get_parent().get_node("destroy_timer").start()
					break ;
	state = move;
				
func _on_destroy_timer_timeout():
	print("_on_destroy_timer_timeout")
	destroy_matched();

func _on_collapse_timer_timeout():
	print("_on_collapse_timer_timeout");
	collapse_columns();
	
func _on_refill_timer_timeout():
	print("_on_refill_timer_timeout");
	refill_columns();
