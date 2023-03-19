extends Label3D

@onready var ParentNode = $"..";

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(ParentNode.get_meta("CellNumber"));
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
