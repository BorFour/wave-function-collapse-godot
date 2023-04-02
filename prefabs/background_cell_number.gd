extends MeshInstance3D

@onready var original_material = self.mesh.material.duplicate();
@onready var original_position = self.position;
const selected_color =  Color(0.6, 0.1, 0.1);  # Red :P


func change_to_not_possible_plays():
	var not_possible_plays_material = self.mesh.material.duplicate();
	not_possible_plays_material.albedo_color = selected_color
	self.mesh.material = not_possible_plays_material;


func reset_material():
	self.mesh.material = original_material;
