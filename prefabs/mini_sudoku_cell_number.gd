extends MeshInstance3D

@onready var deselected_material = self.mesh.material.duplicate();
const selected_color =  Color(0.4, 0.2, 0.5);


func get_selected():
	var cell_number_material = self.mesh.material.duplicate();
	cell_number_material.albedo_color = selected_color
	self.mesh.material = cell_number_material;


func get_deselected():
	self.mesh.material = deselected_material;	
