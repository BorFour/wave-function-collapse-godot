extends Node3D

@onready var algorithm_speed_slider: Slider = $"../VBoxContainer/SpeedSlider";
@onready var cell_prefab = preload("res://prefabs/sudoku_cell.tscn")
@onready var cells = []
const max_seconds_step: float = 2;

var n_rows: int;
var n_columns: int;
var board_size: int;
var valid_numbers: Array;

var rows = {}
var columns = {}
var boxes = {}

var cell_to_row = {}
var cell_to_column = {}
var cell_to_box = {}

# Algorithm variables
var is_algorithm_running: bool = false;


func _ready():
	assert(get_meta("n_rows") > 0, "The number of rows must be a positive number")
	assert(get_meta("n_columns") > 0, "The number of columns must be a positive number")

	spawn(get_meta("n_rows"), get_meta("n_columns"))


func spawn(spawn_n_rows: int, spawn_n_columns: int):

	_clear_data_structures()

	n_rows = spawn_n_rows
	n_columns = spawn_n_columns

	board_size = n_rows * n_columns;
	valid_numbers = range(1, board_size + 1);

	position = Vector3(
		-(board_size * n_columns - 1),
		(board_size * n_rows - 1),
		0
	)

	_spawn_cells()
	_initialize_data_structures()
	_initialize_algorithm()


func _clear_data_structures():
	for cell in cells:
		cell.queue_free()
		
	cells = []

	rows = {}
	columns = {}
	boxes = {}

	cell_to_row = {}
	cell_to_column = {}
	cell_to_box = {}


func _spawn_cells():
	for r in range(board_size):
		for c in range(board_size):
			var child = cell_prefab.instantiate();
			
			child.spawn(
				Vector3(2 * c * n_columns + n_columns / 2.0, -(2 * r * n_rows + n_rows / 2.0), 0)
			)
			add_child(child)
			cells.append(child)


func _initialize_data_structures():
	# Calculate rows, top down
	for row_number in range(1, board_size + 1):
		rows[row_number] = cells.slice((row_number - 1) * board_size, row_number * board_size)

	for row_number in rows.keys():
		for cell in rows[row_number]:
			var cell_index = cells.find(cell)
			cell_to_row[cell_index] = row_number

	# Calculate columns, from left to right
	for column_number in range(1, board_size + 1):
		var column_array = Array()
		for i in range(board_size):
			column_array.append(cells[(column_number - 1) + board_size * i])
		
		columns[column_number] = column_array

	for column_number in columns.keys():
		for cell in columns[column_number]:
			var cell_index = cells.find(cell)
			cell_to_column[cell_index] = column_number


	# Calculate the "offsets" of the elements in the box
	var box_indices = Array()
	for r in range(n_rows):
		box_indices.append_array(range(r * board_size, r * board_size + n_columns));
		
	# Calculate boxes, first from left to right then up down
	for box_number in range(1, board_size + 1):
		var box_array = Array()
		var top_left_index = floor((box_number - 1) / n_rows) * board_size * n_rows + ((box_number - 1) % n_rows) * n_columns;

		# Add the offsets to the top left cell index
		for offset in box_indices:
			box_array.append(cells[top_left_index + offset])
		
		boxes[box_number] = box_array

	for box_number in boxes.keys():
		for cell in boxes[box_number]:
			var cell_index = cells.find(cell)
			cell_to_box[cell_index] = box_number


func _initialize_algorithm():
	for cell_index in range(cells.size()):
		cells[cell_index].hide_unplayable_numbers(get_possible_plays(cell_index))

 
func reset_board():
	var apply_safe_reset = func asdf(x):
		x.safe_reset()

	cells.map(apply_safe_reset)
	_initialize_algorithm()


func get_possible_plays(cell_index: int) -> Array:
	var cell_row_index = cell_to_row[cell_index]
	var cell_column_index = cell_to_column[cell_index]
	var cell_box_index = cell_to_box[cell_index]
	
	# If the cell already selected a number, it can't make any plays
	if cells[cell_index].is_number_selected():
		return []
	
	var neighbors = Array()
	
	for neighbor_cell in rows[cell_row_index] + columns[cell_column_index] + boxes[cell_box_index]:
		if not neighbors.has(neighbor_cell):
			neighbors.append(neighbor_cell)

	var numbers_played_in_neighbors = (
		neighbors
		.filter(func(x): return x.is_number_selected())
		.map(func(x): return x.selected_number)
	)
	
#	print(numbers_played_in_neighbors)

	var valid_plays_for_cell = (
		valid_numbers
		.filter(func(x): return not numbers_played_in_neighbors.has(x))
	)

	return valid_plays_for_cell
	

func has_mininum_entropy(cell_index: int) -> bool:
	
	var min_nonzero_entropy = (
		cells
		.map(func(x): return x.possible_plays.size())
		.filter(func(x): return x > 0)
		.min()
	)

	return cells[cell_index].possible_plays.size() == min_nonzero_entropy


func get_collapsable_candidates() -> Array:
	var all_cells_possible_plays = Array()
	var cells_indeces = range(cells.size())

	for cell in cells:
		all_cells_possible_plays.append(cell.possible_plays)
		
	# Make sure these have the same length before "zipping"
	assert(all_cells_possible_plays.size() == cells.size())
	
	var zip_indeces_possible_plays = Array()
	
	for i in cells_indeces:
		zip_indeces_possible_plays.append(
			[i, all_cells_possible_plays[i].size(), all_cells_possible_plays[i]]
		)
	
	zip_indeces_possible_plays.sort_custom(func (x, y): return x[1] < y[1])
	
	var min_non_zero_value = (
		zip_indeces_possible_plays
		.map(func(x): return x[1])
		.filter(func(x): return x > 0)
		.min()
	)
	
	print("--------------------------")
	print("Min entropy: %s" % min_non_zero_value)
	
	var collapse_candidates = zip_indeces_possible_plays.filter(func(x): return x[1] == min_non_zero_value)
	
	return collapse_candidates

func try_to_select_number(cell_node: Node3D, selected_play: int):
	var cell_index = cells.find(cell_node);
	
	if (
		not cell_node.is_number_selected()
		and not cell_node.possible_plays.has(selected_play)
	):
		# Selection not possible
		return
	elif (
		not has_mininum_entropy(cell_index)
	):
		cell_node.shake_incorrect_play()
		return
	
	cell_node.safe_select_number(selected_play)
	propagate()


func propagate():
	"""Returns a boolean indicating whether the algorithm should continue."""
	
	var cells_without_possible_plays = [];

	for cell_index in range(cells.size()):
		var cell = cells[cell_index];
		var possible_plays = get_possible_plays(cell_index);

		cell.hide_unplayable_numbers(possible_plays);
		
		if (
			not cell.is_number_selected()
			and possible_plays.size() == 0
		):
			cells_without_possible_plays.append(cell)
			continue
	
	if cells_without_possible_plays.size() > 0:
		for cell in cells_without_possible_plays:
			cell.highlight_not_possible_plays()
	
	return cells_without_possible_plays.size() == 0


func collapse_one_wave(candidates: Array):
	var selected_candidate = candidates.pick_random()
	var selected_play = selected_candidate[2].pick_random()
	
	print("Collapse with:")
	print(selected_candidate, " -> ", selected_play)
	
	
	cells[selected_candidate[0]].safe_select_number(selected_play)


func step() -> bool:
	"""Return value tells where it can keep running."""
	var candidates = get_collapsable_candidates()
	
	if candidates.size() == 0:
		return false

	collapse_one_wave(candidates)
	return propagate()


func run():
	# Maybe wave function collapse doesn't always find a solution
	# SEE: https://news.ycombinator.com/item?id=18445466
	# SEE: https://dev.to/aspittel/how-i-finally-wrote-a-sudoku-solver-177g

	is_algorithm_running = true;
	while is_algorithm_running:
		var can_continue = step()

		if not can_continue:
			break
		
		# Wait for the inverse of the value of the slider
		await get_tree().create_timer((1 - sqrt(algorithm_speed_slider.value)) * max_seconds_step).timeout
	
	print("Done!")
	is_algorithm_running = false;
