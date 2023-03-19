extends MeshInstance3D


var mouseHoveringOverCellNumber: bool = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	if mouseHoveringOverCellNumber:
		print("asdf")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
