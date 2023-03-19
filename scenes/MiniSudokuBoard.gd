extends Node3D

const n_rows: int = 4;
const n_columns: int = 4;
const n_boxes: int = 4;

const valid_numbers = [1, 2, 3, 4];

const algorithm_step_seconds: float = 1.0;

@onready var cells = [
	$MiniSudokuCell1,
	$MiniSudokuCell2,
	$MiniSudokuCell3,
	$MiniSudokuCell4,
	$MiniSudokuCell5,
	$MiniSudokuCell6,
	$MiniSudokuCell7,
	$MiniSudokuCell8,
	$MiniSudokuCell9,
	$MiniSudokuCell10,
	$MiniSudokuCell11,
	$MiniSudokuCell12,
	$MiniSudokuCell13,
	$MiniSudokuCell14,
	$MiniSudokuCell15,
	$MiniSudokuCell16,
]

var rows = {}
var columns = {}
var boxes = {}

var cell_to_row = {}
var cell_to_column = {}
var cell_to_box = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate rows, top down
	for row_number in range(1, n_rows + 1):
		rows[row_number] = cells.slice((row_number - 1) * 4, row_number * 4)

	for row_number in rows.keys():
		for cell in rows[row_number]:
			var cell_index = cells.find(cell)
			cell_to_row[cell_index] = row_number

	# Calculate columns, from left to right
	for column_number in range(1, n_columns + 1):
		var column_array = Array()
		for i in range(4):
			column_array.append(cells[(column_number - 1) + 4 * i])
		
		columns[column_number] = column_array

	for column_number in columns.keys():
		for cell in columns[column_number]:
			var cell_index = cells.find(cell)
			cell_to_column[cell_index] = column_number

	# Calculate boxes, first from left to right then up down
	for box_number in range(1, n_boxes + 1):
		var box_array = Array()
		var top_left_index = ((box_number - 1) % 2) * 2 + floor((box_number - 1) / 2) * 8

		for offset in [0, 1, 4, 5]:
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

	var valid_plays_for_cell = (
		valid_numbers
		.filter(func(x): return not numbers_played_in_neighbors.has(x))
	)

	return valid_plays_for_cell

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
	return true


func run():
	while true:
		var can_continue = step()

		if not can_continue:
			break

		await get_tree().create_timer(algorithm_step_seconds).timeout

	print("Done!")
