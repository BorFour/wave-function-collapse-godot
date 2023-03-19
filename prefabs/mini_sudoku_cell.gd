extends Node3D

@onready var number_cells = {
	1: $Row1Column1,
	2: $Row1Column2,
	3: $Row2Column1,
	4: $Row2Column2,
}


func _deselect_all_cells():
	for cell in number_cells.values():
		cell.get_deselected()


func select_number_cell_by_number(num: int):
	if get_meta("SelectedNumber") >= 1:
		print("Can't select another number")
		return
		
	var cell_to_select = number_cells[num];

	self._deselect_all_cells()
	cell_to_select.get_selected()
	
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(cell_to_select, "position", Vector3(0, 1, 0.1), 0.5)
	tween.tween_property(cell_to_select, "scale", Vector3(1, 1, 1), 0.5)

	set_meta("SelectedNumber", num);
