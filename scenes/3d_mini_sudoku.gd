extends Node3D

@onready var camera = $Camera3D;
@onready var mini_sudoku_board = $MiniSudokuBoard;


func _ready():
	position_camera(mini_sudoku_board.get_meta("n_rows"), mini_sudoku_board.get_meta("n_columns"))


func position_camera(n_rows: int, n_columns: int):
	camera.position = Vector3(0, 0,(pow(max(n_rows, n_columns), 2) * 6))


func raycast_from_camera_to_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = 2
	
	var raycast_result = space.intersect_ray(ray_query)
	
	return raycast_result.collider if raycast_result.has("collider") else null


func _unhandled_input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):

		var collider = raycast_from_camera_to_mouse()
		
		if collider != null:
			var cell_number_node = collider.get_parent()
			var number_selected = cell_number_node.get_meta("CellNumber")
			var cell_node = cell_number_node.get_parent()

			if cell_node.can_be_clicked():
				mini_sudoku_board.try_to_select_number(cell_node, number_selected)
			else:
				print("Can't click the cell right now")
