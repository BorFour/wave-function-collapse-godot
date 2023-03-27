extends MeshInstance3D

@onready var original_material = self.mesh.material.duplicate();
@onready var original_position = self.position;
const selected_color =  Color(0.1, 0.6, 0.1);  # Green :O
var number: int;


func spawn(spawn_position: Vector3, cell_number: int):
	"""This method is called when the prefab is spawned dynamically."""

	number = cell_number
	original_position = spawn_position
	position = spawn_position
	$NumberText._ready()
	
	
func get_selected():
	var cell_number_material = self.mesh.material.duplicate();
	cell_number_material.albedo_color = selected_color
	self.mesh.material = cell_number_material;


func get_deselected():
	self.mesh.material = original_material;
