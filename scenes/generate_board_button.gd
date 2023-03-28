extends Button

@onready var sudoku_board = $"../../SudokuBoard";
@onready var parent_scene = $"../..";
@onready var n_rows_slider = $"../../VBoxContainer/NRowsSlider";
@onready var n_columns_slider = $"../../VBoxContainer/NColumnsSlider";


func _pressed():
	sudoku_board.spawn(n_rows_slider.value, n_columns_slider.value);
	parent_scene.position_camera(sudoku_board.n_rows, sudoku_board.n_columns)
