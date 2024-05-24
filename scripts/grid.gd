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
@export var empty_spaces: PackedVector2Array
@export var ice_spaces: PackedVector2Array
@export var lock_spaces: PackedVector2Array
@export var concrete_spaces: PackedVector2Array
@export var slime_spaces: PackedVector2Array

# Obstacle Signal
signal make_ice
signal damage_ice
signal make_lock
signal damage_lock
signal make_concrete
signal damage_concrete
signal make_slime
signal damage_slime

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
	state = move
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	spawn_ice()
	spawn_locks()
	spawn_concrete()
	spawn_slime()
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

func restricted_fill(place):
	if is_in_array(empty_spaces, place):
		return true
	if is_in_array(concrete_spaces, place):
		return true
	if is_in_array(slime_spaces, place):
		return true
	return false

func restricted_move(place):
	if is_in_array(lock_spaces, place):
		return true
	return false

func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false

func remove_from_array(array, item):
	for i in range(array.size() - 1, -1, -1):
		if array[i] == item:
			array.remove_at(i)
# create random color pieces
# NOTE: should add code to avoid match when first generated
func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i, j)):
				# choose a random number and store it
				var rand = floor(randf_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instantiate(); # instance() func is no longer used;
				while (match_at(i, j, piece.color)):
					rand = floor(randf_range(0, possible_pieces.size()));
					piece = possible_pieces[rand].instantiate();
				piece.position = grid_to_pixel(i, j)
				all_pieces[i][j] = piece;
				add_child(piece);

func spawn_ice():
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i])

func spawn_locks():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])

func spawn_concrete():
	for i in concrete_spaces.size():
		emit_signal("make_concrete", concrete_spaces[i])

func spawn_slime():
	for i in slime_spaces.size():
		emit_signal("make_slime", slime_spaces[i])

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

	if first_piece != null&&other_piece != null:
		if !restricted_move(Vector2(column, row))&&!restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = wait
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
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
			if all_pieces[i][j] == null&&!restricted_fill(Vector2(i, j)):
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
			if !is_piece_null(i, j):
				var current_color = all_pieces[i][j].color
				if i > 0&&i < width - 1:
					if !is_piece_null(i - 1, j)&&!is_piece_null(i + 1, j):
							if all_pieces[i - 1][j].color == current_color&&all_pieces[i + 1][j].color == current_color:
								match_and_dim(all_pieces[i][j])
								match_and_dim(all_pieces[i - 1][j])
								match_and_dim(all_pieces[i + 1][j])
								matched = true
				if j > 0&&j < height - 1:
					if !is_piece_null(i, j - 1)&&!is_piece_null(i, j + 1):
							if all_pieces[i][j - 1].color == current_color&&all_pieces[i][j + 1].color == current_color:
								match_and_dim(all_pieces[i][j])
								match_and_dim(all_pieces[i][j - 1])
								match_and_dim(all_pieces[i][j + 1])
								matched = true
	if matched == true:
		get_parent().get_node("destroy_timer").start();
	else:
		swap_back();

func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false

func match_and_dim(item):
	item.matched = true
	item.dim()

# find and destroy matched pieces
func destroy_matched():
	var destroyed = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					damage_specical(i, j)
					destroyed = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	if destroyed == true:
		get_parent().get_node("collapse_timer").start()

func check_concrete(column, row):
	if column < width - 1:
		emit_signal("damage_concrete", Vector2(column + 1, row))
	if column > 0:
		emit_signal("damage_concrete", Vector2(column - 1, row))
	if row < height - 1:
		emit_signal("damage_concrete", Vector2(column, row + 1))
	if row > 0:
		emit_signal("damage_concrete", Vector2(column, row - 1))

func check_slime(column, row):
	if column < width - 1:
		emit_signal("damage_slime", Vector2(column + 1, row))
	if column > 0:
		emit_signal("damage_slime", Vector2(column - 1, row))
	if row < height - 1:
		emit_signal("damage_slime", Vector2(column, row + 1))
	if row > 0:
		emit_signal("damage_slime", Vector2(column, row - 1))

func damage_specical(column, row):
	emit_signal("damage_ice", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))
	check_concrete(column, row)
	check_slime(column, row)

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null&&!restricted_fill(Vector2(i, j)):
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

func _on_lock_holder_remove_lock(place):
	remove_from_array(lock_spaces, place)

func _on_concrete_holder_remove_concrete(place):
	remove_from_array(concrete_spaces, place)


func _on_slime_holder_remove_slime(place):
	remove_from_array(slime_spaces, place)
