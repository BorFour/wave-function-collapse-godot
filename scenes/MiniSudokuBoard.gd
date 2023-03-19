extends Node3D

const n_rows: int = 4;
const n_columns: int = 4;

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
	var row = 1;
	var column = 1;
	
	for cell in cells:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
