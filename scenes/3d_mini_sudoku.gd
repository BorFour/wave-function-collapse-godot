extends Node3D

@onready var camera = $Camera3D;
var ray;

# Called when the node enters the scene tree for the first time.
func _ready():
	ray = RayCast3D.new()
	ray.set_enabled(true)
	ray.set_name("RayCast_cells")


func raycast_from_camera_to_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	var raycast_result = space.intersect_ray(ray_query)
	
	print(raycast_result)
	
	return raycast_result.collider

func _unhandled_input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
	
		var collider = raycast_from_camera_to_mouse()
		var cell_number_node = collider.get_parent()
		
		print(cell_number_node)
		
		var cell_number_material = cell_number_node.mesh.material.duplicate();
		cell_number_material.albedo_color = Color(0.5, 0, 0)
		cell_number_node.mesh.material = cell_number_material;


