extends Label3D

@onready var parent_node = $"..";

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(parent_node.number);
