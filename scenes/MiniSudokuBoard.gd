extends Node3D

const n_rows: int = 4;
const n_columns: int = 4;
const n_boxes: int = 4;

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

# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate rows, top down
	for row_number in range(1, n_rows + 1):
		rows[row_number] = cells.slice((row_number - 1) * 4, row_number * 4)
	
#	print(rows)
	
	# Calculate columns, from left to right
	for column_number in range(1, n_columns + 1):
		var column_array = Array()
		for i in range(4):
			column_array.append(cells[(column_number - 1) + 4 * i])
		
		columns[column_number] = column_array
	
#	print(columns)

	# Calculate boxes, first from left to right then up down
	for box_number in range(1, n_boxes + 1):
		var box_array = Array()
		var top_left_index = ((box_number - 1) % 2) * 2 + floor((box_number - 1) / 2) * 8
			
		for offset in [0, 1, 4, 5]:
			box_array.append(cells[top_left_index + offset])
		
		boxes[box_number] = box_array
	
#	print(boxes)
