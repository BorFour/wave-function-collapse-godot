extends Button

@onready var mini_sudoku_board = $"../../MiniSudokuBoard";
@onready var parent_scene = $"../..";
@onready var n_rows_slider = $"../../VBoxContainer/NRowsSlider";
@onready var n_columns_slider = $"../../VBoxContainer/NColumnsSlider";


func _pressed():
	mini_sudoku_board.spawn(n_rows_slider.value, n_columns_slider.value);
	parent_scene.position_camera(mini_sudoku_board.n_rows, mini_sudoku_board.n_columns)
