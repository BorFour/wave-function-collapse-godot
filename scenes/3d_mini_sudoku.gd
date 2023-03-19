extends Node3D

@onready var camera = $Camera3D;


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
			cell_number_node.get_parent().select_number_cell_by_number(number_selected)
