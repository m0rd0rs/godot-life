extends Node2D

@onready var tile_map = $Field

func _ready():
	# Fill 150x150 with blue (atlas index 0,0)
	for x in range(150):
		for y in range(150):
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	# F pentomino (R-pentomino) in grey (atlas index 4,0)
	var center_x = 75
	var center_y = 75
	var pentomino = [
		Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(1, 2)
	]
	# Offset to put it roughly in the center
	var offset = Vector2i(center_x - 1, center_y - 1)
	for p in pentomino:
		tile_map.set_cell(p + offset, 0, Vector2i(4, 0))

	# Center the camera
	var camera = Camera2D.new()
	add_child(camera)
	camera.position = Vector2(150 * 16 / 2, 150 * 16 / 2)
	camera.zoom = Vector2(0.3, 0.3)
	camera.make_current()
