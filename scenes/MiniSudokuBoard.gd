extends Node3D

@onready var algorithm_step_seconds_slider: Slider = $"../VBoxContainer/SecondsBetweenStepsSlider";
@onready var cell_prefab = preload("res://prefabs/mini_sudoku_cell.tscn")
@onready var cells = []

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


func _ready():
	assert(get_meta("n_rows") > 0, "The number of rows must be a positive number")
	assert(get_meta("n_columns") > 0, "The number of columns must be a positive number")

	n_rows = get_meta("n_rows");
	n_columns = get_meta("n_columns");
	board_size = n_rows * n_columns;
	valid_numbers = range(1, board_size + 1);

	position = Vector3(
		-(board_size * n_columns - 1),
		(board_size * n_rows - 1),
		0
	)

	_spawn_cells()
	_initialize_data_structures()
	

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

 
func reset_board():
	var apply_safe_reset = func asdf(x):
		x.safe_reset()

	cells.map(apply_safe_reset)


func get_possible_plays(cell_index: int) -> Array:
	var cell_row_index = cell_to_row[cell_index]
	var cell_column_index = cell_to_column[cell_index]
	var cell_box_index = cell_to_box[cell_index]
	
	# If the cell already selected a number, it can't make any plays
	if cells[cell_index]._is_number_selected():
		return []
	
	var neighbors = Array()
	
	for neighbor_cell in rows[cell_row_index] + columns[cell_column_index] + boxes[cell_box_index]:
		if not neighbors.has(neighbor_cell):
			neighbors.append(neighbor_cell)

	var numbers_played_in_neighbors = (
		neighbors
		.filter(func(x): return x._is_number_selected())
		.map(func(x): return x.get_meta("SelectedNumber"))
	)
	
#	print(numbers_played_in_neighbors)

	var valid_plays_for_cell = (
		valid_numbers
		.filter(func(x): return not numbers_played_in_neighbors.has(x))
	)

	return valid_plays_for_cell
	

func has_mininum_entropy(cell_index: int) -> bool:
	
	var min_nonzero_entropy = (
		range(cells.size())
		.map(func(x): return get_possible_plays(x).size())
		.filter(func(x): return x > 0)
		.min()
	)

	return get_possible_plays(cell_index).size() == min_nonzero_entropy


func get_collapasable_candidates() -> Array:
	var all_cells_possible_plays = Array()
	var cells_indeces = range(cells.size())

	for i in cells_indeces:
		all_cells_possible_plays.append(get_possible_plays(i))
		
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
	
	var collapse_candidates = zip_indeces_possible_plays.filter(func(x): return x[1] == min_non_zero_value)
	
	return collapse_candidates

func try_to_select_number(cell_node: Node3D, selected_play: int):
	var cell_index = cells.find(cell_node);
	
	if (
		not cell_node._is_number_selected()
		and not get_possible_plays(cell_index).has(selected_play)
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
	for cell_index in range(cells.size()):
		cells[cell_index].hide_unplayable_numbers(get_possible_plays(cell_index))


func collapse_one_wave(candidates: Array):
	var selected_candidate = candidates.pick_random()
	var selected_play = selected_candidate[2].pick_random()
	
	cells[selected_candidate[0]].safe_select_number(selected_play)


func step() -> bool:
	"""Return value tells where it can keep running."""
	var candidates = get_collapasable_candidates()
	
	if candidates.size() == 0:
		return false

	collapse_one_wave(candidates)
	propagate()
	return true


func run():
	while true:
		var can_continue = step()

		if not can_continue:
			break
		
		await get_tree().create_timer(algorithm_step_seconds_slider.value).timeout

	print("Done!")
