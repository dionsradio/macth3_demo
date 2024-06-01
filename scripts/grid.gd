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
var damaged_slime = false

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
	preload ("res://scenes/pieces/yellow_piece.tscn"),
	preload ("res://scenes/pieces/green_piece.tscn"),
	preload ("res://scenes/pieces/blue_piece.tscn"),
	#preload ("res://scenes/pieces/light_green_piece.tscn"),
	 preload ("res://scenes/pieces/pink_piece.tscn"),
	 preload ("res://scenes/pieces/orange_piece.tscn"),
];

# generated pieces
var all_pieces = []
var current_matched = []

# Swap Back Variables;
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)

# touch variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var controlling = false;

# Scoring variables
signal update_score
@export var piece_value: int
var streak = 1

# Counter
signal update_counter
@export var current_counter_value:int
@export var is_moves:bool
signal game_over

# Effects
var particle_effect = preload("res://scenes/particles/ParticleEffect.tscn")
var animated_effect = preload("res://scenes/particles/AnimatedExplosion.tscn")

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
	emit_signal("update_counter", current_counter_value)
	if !is_moves:
		$Timer.start();

	# _debug_make_color_bomb(5, 3)
	# _debug_make_row_bomb(3, 3)
	# _debug_make_row_bomb(4, 3)
	# _debug_make_column_bomb(4, 4)
	# _debug_make_column_bomb(4, 5)

func _debug_make_column_bomb(_col, _row):
	if all_pieces[_col][_row] != null:
		all_pieces[_col][_row].make_column_bomb()
	
func _debug_make_row_bomb(_col, _row):
	if all_pieces[_col][_row] != null:
		all_pieces[_col][_row].make_row_bomb()
func _debug_make_color_bomb(_col, _row):
	if all_pieces[_col][_row] != null:
		all_pieces[_col][_row].make_color_bomb()

func _debug_make_random_color_bomb():
	var _col = floor(randf_range(0, width))
	var _row = floor(randf_range(0, height))
	print("col:", _col, ", row:", _row)
	_debug_make_color_bomb(_col, _row)

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

func add_to_array(item, array):
	if !array.has(item):
		array.append(item)

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

func is_in_grid(grid_position: Vector2):
	if grid_position.x >= 0&&grid_position.x < width&&grid_position.y >= 0&&grid_position.y < height:
		return true
	return false

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
			if is_color_bomb(first_piece, other_piece):
				if first_piece.color != "Color":
					#other_piece.matched = true
					match_and_dim(other_piece)
					add_to_array(Vector2(column, row), current_matched)
					match_color(first_piece.color)
				elif other_piece.color != "Color":
					#first_piece.matched = true
					match_and_dim(first_piece)
					add_to_array(Vector2(column + direction.x, row + direction.y), current_matched)
					match_color(other_piece.color)
				else:
					first_piece.matched = true
					other_piece.matched = true
					clear_board()
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

func is_color_bomb(p1, p2):
	if p1.color == "Color" or p2.color == "Color":
		return true
	return false

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
								add_to_array(Vector2(i, j), current_matched)
								add_to_array(Vector2(i - 1, j), current_matched)
								add_to_array(Vector2(i + 1, j), current_matched)
				if j > 0&&j < height - 1:
					if !is_piece_null(i, j - 1)&&!is_piece_null(i, j + 1):
							if all_pieces[i][j - 1].color == current_color&&all_pieces[i][j + 1].color == current_color:
								match_and_dim(all_pieces[i][j])
								match_and_dim(all_pieces[i][j - 1])
								match_and_dim(all_pieces[i][j + 1])
								add_to_array(Vector2(i, j), current_matched)
								add_to_array(Vector2(i, j - 1), current_matched)
								add_to_array(Vector2(i, j + 1), current_matched)
	if current_matched.size() > 0:
		get_bombed_pieces()
		get_parent().get_node("destroy_timer").start()
	else:
		swap_back()

func get_bombed_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					if all_pieces[i][j].is_column_bomb:
						match_all_in_column(i)
					if all_pieces[i][j].is_row_bomb:
						match_all_in_row(j)
					if all_pieces[i][j].is_adjacent_bomb:
						find_adjacent_pieces(i, j)

func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false

func find_bombs():
	# Iterate over the current_matched array
	for i in current_matched.size():
		var curr_column = current_matched[i].x
		var curr_row = current_matched[i].y
		var curr_color = all_pieces[curr_column][curr_row].color
		var matched_col = 0
		var matched_row = 0
		for j in current_matched.size():
				var next_column = current_matched[j].x
				var next_row = current_matched[j].y
				var next_color = all_pieces[next_column][next_row].color
				if next_color == curr_color&&next_column == curr_column:
					matched_col += 1
				if next_color == curr_color&&next_row == curr_row:
					matched_row += 1
		
		# TODO: 这里有一些问题。
		# 总是会先匹配到 row_bomb 或 column_bomb 
		# 因为在往 current_matched 中添加时，总是先添加一整行或一整列
		if matched_col >= 3&&matched_row >= 3:
			make_bomb(0, curr_color)
			print("adjacent bomb")
			return
		if matched_col == 4:
			print("column bomb")
			make_bomb(1, curr_color)
			return
		if matched_row == 4:
			print("row bomb")
			make_bomb(2, curr_color)
			return
		if matched_col == 5 or matched_row == 5:
			print("color bomb")
			make_bomb(3, curr_color)
			return

func make_bomb(bomb_type, color):
	for i in current_matched.size():
		var curr_col = current_matched[i].x
		var curr_row = current_matched[i].y
		if all_pieces[curr_col][curr_row] == piece_one and piece_one.color == color:
			piece_one.matched = false
			change_bomb(bomb_type, piece_one)
		if all_pieces[curr_col][curr_row] == piece_two and piece_two.color == color:
			piece_two.matched = false
			change_bomb(bomb_type, piece_two)

func change_bomb(bomb_type, piece):
	if bomb_type == 0:
		piece.make_adjacent_bomb()
	if bomb_type == 1:
		piece.make_column_bomb()
	if bomb_type == 2:
		piece.make_row_bomb()
	if bomb_type == 3:
		piece.make_color_bomb()

func match_and_dim(item):
	item.matched = true
	item.dim()

# find and destroy matched pieces
func destroy_matched():
	find_bombs()
	var destroyed = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					if all_pieces[i][j].color == "Color":
						print("Color Bomb")
					damage_specical(i, j)
					destroyed = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					make_effect(particle_effect, i, j)
					make_effect(animated_effect, i, j)
					emit_signal("update_score", piece_value * streak)
	if destroyed == true:
		get_parent().get_node("collapse_timer").start()
	current_matched.clear()

func make_effect(effect, column, row):
	var current = effect.instantiate()
	current.position = grid_to_pixel(column, row)
	add_child(current)
	pass

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

func match_color(color):
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].color == color:
					#all_pieces[i][j].match_and_dim()
					match_and_dim(all_pieces[i][j])
					add_to_array(Vector2(i, j), current_matched)

func clear_board():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				#all_pieces[i][j].match_and_dim()
				match_and_dim(all_pieces[i][j])
				add_to_array(Vector2(i, j), current_matched)

func refill_columns():
	streak += 1
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
					return
	if !damaged_slime:
		generate_slime()
	state = move
	streak = 1
	damaged_slime = false
	current_counter_value -= 1
	emit_signal("update_counter")
	if current_counter_value == 0:
		declare_game_over()

func generate_slime():
	if slime_spaces.size() > 0:
		var slime_made = false
		var tracker = 0
		while !slime_made: # and tracker < 100:
			var random_num = floor(randf_range(0, slime_spaces.size()))
			var current_x = slime_spaces[random_num].x
			var current_y = slime_spaces[random_num].y
			var neighbor = find_normal_neighbor(current_x, current_y)
			if neighbor != null:
				# Turn that neighbor into a slime
				# Remove that piece
				all_pieces[neighbor.x][neighbor.y].queue_free()
				all_pieces[neighbor.x][neighbor.y] = null

				slime_spaces.append(Vector2(neighbor.x, neighbor.y))
				emit_signal("make_slime", Vector2(neighbor.x, neighbor.y))
				slime_made = true
			#tracker += 1

func find_normal_neighbor(column, row):
	# find right
	if is_in_grid(Vector2(column + 1, row)):
		if !is_piece_null(column + 1, row):
			return Vector2(column + 1, row)
	# find left
	if is_in_grid(Vector2(column - 1, row)):
		if !is_piece_null(column - 1, row):
			return Vector2(column - 1, row)
	# find above
	if is_in_grid(Vector2(column, row + 1)):
		if !is_piece_null(column, row + 1):
			return Vector2(column, row + 1)
	# find bellow
	if is_in_grid(Vector2(column, row - 1)):
		if !is_piece_null(column, row - 1):
			return Vector2(column, row - 1)
	return null

# TODO: 下面 3 个方法会造成死循环，如果一个范围内同时出现多种类型的 bomb 时
func match_all_in_column(column):
	for i in height:
		if all_pieces[column][i] != null:
			all_pieces[column][i].matched = true
			if all_pieces[column][i].is_row_bomb:
				match_all_in_row(i)
			if all_pieces[column][i].is_adjacent_bomb:
				find_adjacent_pieces(column, i)

func match_all_in_row(row):
	for i in width:
		if all_pieces[i][row] != null:
			all_pieces[i][row].matched = true
			if all_pieces[i][row].is_column_bomb:
				match_all_in_column(i)
			if all_pieces[i][row].is_adjacent_bomb:
				find_adjacent_pieces(i, row)

func find_adjacent_pieces(column, row):
	for i in range( - 1, 2):
		for j in range( - 1, 2):
			if is_in_grid(Vector2(column + i, row + j)):
				if all_pieces[column + i][row + j] != null:
					all_pieces[column + i][row + j].matched = true;
				if all_pieces[column + i][row + j].is_column_bomb:
					match_all_in_column(column + i)
				if all_pieces[column + i][row + j].is_row_bomb:
					match_all_in_row(row + j)

func _on_destroy_timer_timeout():
	#print("_on_destroy_timer_timeout")
	destroy_matched();

func _on_collapse_timer_timeout():
	#print("_on_collapse_timer_timeout")
	collapse_columns();
	
func _on_refill_timer_timeout():
	#print("_on_refill_timer_timeout")
	refill_columns();

func _on_lock_holder_remove_lock(place):
	remove_from_array(lock_spaces, place)

func _on_concrete_holder_remove_concrete(place):
	remove_from_array(concrete_spaces, place)

func _on_slime_holder_remove_slime(place):
	#print("_on_slime_holder_remove_slime:", place)
	damaged_slime = true
	remove_from_array(slime_spaces, place)

func _on_timer_timeout():
	current_counter_value -= 1
	emit_signal("update_counter")
	if current_counter_value == 0:
		declare_game_over()
		$Timer.stop()

func declare_game_over():
	emit_signal("game_over")
	state = wait
