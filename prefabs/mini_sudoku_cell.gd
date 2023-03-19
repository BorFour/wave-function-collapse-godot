extends Node3D

@onready var number_cells = {
	1: $Row1Column1,
	2: $Row1Column2,
	3: $Row2Column1,
	4: $Row2Column2,
}

@onready var select_mutex = Mutex.new();
@onready var can_click = true;
const tween_animation_step_time: float = 0.3;


func _set_can_click_to_true():
	can_click = true;
	

func _deselect_all_cells():
	for cell in number_cells.values():
		cell.get_deselected()


func _select_number_cell_by_number(num: int):
	var cell_to_select = number_cells[num];
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	_deselect_all_cells()

	cell_to_select.get_selected()

	tween.tween_property(cell_to_select, "position", Vector3(0, 1, 0.1), tween_animation_step_time)
	tween.tween_property(cell_to_select, "scale", Vector3(1, 1, 1), tween_animation_step_time)
	tween.tween_callback(_set_can_click_to_true)

	set_meta("SelectedNumber", num);


func _delect_selected_number():
	var cell_to_select = number_cells[get_meta("SelectedNumber")];
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(cell_to_select, "scale", Vector3(0.5, 0.5, 0.5), tween_animation_step_time)
	tween.tween_property(cell_to_select, "position", cell_to_select.original_position, tween_animation_step_time)
	tween.tween_callback(cell_to_select.get_deselected)
	tween.tween_callback(_set_can_click_to_true)

	set_meta("SelectedNumber", -1);


func click_number_cell_by_number(num: int):
	if not can_click:
		return

	select_mutex.lock()
	can_click = false;
	
	var selected_number = get_meta("SelectedNumber");
	if selected_number >= 1:
		
		if selected_number != num:
			print("Oopsie")
			can_click = true;
			select_mutex.unlock()
			return

		_delect_selected_number()
	else:
		_select_number_cell_by_number(num)
	select_mutex.unlock()
