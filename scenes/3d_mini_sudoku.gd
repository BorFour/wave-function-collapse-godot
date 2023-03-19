extends Node3D

@onready var camera = $Camera3D;
var ray;

# Called when the node enters the scene tree for the first time.
func _ready():
	ray = RayCast3D.new()
	ray.set_name("RayCast_cells")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse = get_viewport().get_mouse_position()
	var asdf = camera.project_ray_normal(mouse);
	
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(camera.position, asdf)
	var result = space_state.intersect_ray(query)
	
	print(result)
#    # use global coordinates, not local to node
#    var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
#    var result = space_state.intersect_ray(query)

	
