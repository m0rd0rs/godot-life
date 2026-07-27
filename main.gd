extends Node2D

@onready var tile_map = $Field
@onready var camera = $Camera

var board_size: int = 175
var center_x = board_size / 2.0
var center_y = board_size / 2.0
var map_drag = false
var running = false
var one_step = false
var map_source: Dictionary[Vector2i, bool] = {}
var map_target: Dictionary[Vector2i, bool] = {}


func _ready():

	# Fill board with blue
	for x in range(board_size):
		for y in range(board_size):
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

# https://www.youtube.com/watch?v=bTPN3spiq1I
# ToDo: Check if it's worth it to do all of them
	# Default board is F-pentomino
	var pentomino = [
		Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(1, 2)
	]

	# Offset to put it roughly in the center
	var offset = Vector2i(floori(center_x - 1), floori(center_y - 1)) # I hate rounding warnings!
	for p in pentomino:
		tile_map.set_cell(p + offset, 0, Vector2i(4, 0))
		if ! map_source.has(p + offset):
			map_source.set(p + offset, true)

	# Center the camera
	camera.position = Vector2(board_size * 16.0 / 2, board_size * 16.0 / 2)
	camera.zoom = Vector2(0.3, 0.3)
	camera.make_current()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()# Close on ESC

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			map_drag = true
		else:
			map_drag = false

	if event is InputEventMouseMotion and map_drag:
			camera.position -= event.relative / camera.zoom

	if event.is_action_pressed("zoom in"):
		camera.zoom = (camera.zoom + Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))
	
	if event.is_action_pressed("zoom out"):
		camera.zoom = (camera.zoom - Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))


func _on_ui_start_stop_toggle() -> void:
	running = !running


func _on_ui_step() -> void:
	one_step = true


func _process(_delta: float) -> void:
	if running or one_step:
		process_cycle()
	one_step = false

func process_cycle():
	var neighbours = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                   Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]
	map_target = {}
	for cell in map_source:
		for adjacent in neighbours:
			var count = 0
			var test_cell = cell + adjacent
			for neighbour in neighbours:
				if  map_source.has(test_cell + neighbour):
					count += 1

			if count < 2 and map_source.has(test_cell):
				tile_map.set_cell(test_cell, 0, Vector2i(0, 0))

			if count == 2 and map_source.has(test_cell):
				if !map_target.has(test_cell):
					map_target[test_cell] = true
			else:
				tile_map.set_cell(test_cell, 0, Vector2i(0, 0))

			if count == 3:
				if !map_target.has(test_cell):
					map_target[test_cell] = true
				tile_map.set_cell(test_cell, 0, Vector2i(4, 0))

			if count > 3:
				if map_source.has(test_cell):
					tile_map.set_cell(test_cell, 0, Vector2i(0, 0))

	map_source = map_target
