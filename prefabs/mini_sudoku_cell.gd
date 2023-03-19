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
	var cell_to_select = number_cells[num];

	self._deselect_all_cells()
	cell_to_select.get_selected()
