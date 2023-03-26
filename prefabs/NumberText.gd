extends Label3D

@onready var ParentNode = $"..";

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(ParentNode.get_meta("CellNumber"));
