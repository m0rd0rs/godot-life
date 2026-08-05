extends Node2D

@onready var tile_map = $Field
@onready var ocean_floor = $OceanFloor
@onready var camera = $Camera
@onready var preset_list = $UI/PresetContainer/Presets

var board_size: int = 400
var center_x = board_size / 2.0
var center_y = board_size / 2.0
var map_drag = false
var running = false
var one_step = false
var map_source: Dictionary[Vector2i, bool] = {}
var map_target: Dictionary[Vector2i, bool] = {}
var drawing = false
var cycles = 0
var old_tile_pos = Vector2i(0, 0)
var current_preset = 0

const SAVE_PATH = "res://presets/"

signal cycle

func _ready():
	populate_presets()
	_set_default()

func _set_default():
	# Fill board with base tile 0
	for x in range(board_size):
		for y in range(board_size):
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			ocean_floor.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

# https://www.youtube.com/watch?v=bTPN3spiq1I
# ToDo: Check if it's worth it to do all of them
	# Default board is F-pentomino
	var preset = load_preset(current_preset)

	# Offset to put it roughly in the center
	for p in preset.keys():
		tile_map.set_cell(p, 0, Vector2i(4, 0))
		if ! map_source.has(p):
			map_source.set(p, true)

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

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed
		if drawing:
			_draw_tile_at_mouse_xy()
	elif event is InputEventMouseMotion and drawing:
		_draw_tile_at_mouse_xy()

	if event.is_action_pressed("zoom in"):
		camera.zoom = (camera.zoom + Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))
	
	if event.is_action_pressed("zoom out"):
		camera.zoom = (camera.zoom - Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))


func _on_ui_start_stop_toggle() -> void:
	running = !running


func _on_ui_step() -> void:
	one_step = true


func _on_ui_reset() -> void:
	running = false
	map_source = {}
	_set_default()
	cycles = 0
	cycle.emit(cycles)


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

			if count == 2 and map_source.has(test_cell): # Remain the same.
				if !map_target.has(test_cell):
					map_target[test_cell] = true

			if count == 3: # New life is born.
				if !map_target.has(test_cell):
					map_target[test_cell] = true

	cycles += 1
	cycle.emit(cycles)

	for cell in map_source: # cleanup
		tile_map.set_cell(cell, 0, Vector2i(0, 0))

	map_source = map_target

	for cell in map_source: # redraw
		tile_map.set_cell(cell, 0, Vector2i(4, 0))
		var atlas_index = ocean_floor.get_cell_atlas_coords(cell)
		if atlas_index.x < 15:
			ocean_floor.set_cell(cell, 0, Vector2i(atlas_index.x + 1, 0))


func _draw_tile_at_mouse_xy():
	var mouse_pos = tile_map.get_local_mouse_position()
	var tile_pos = tile_map.local_to_map(mouse_pos)
	if not old_tile_pos == tile_pos: # Prevent changing tile unless we moved mouse.
		if not map_source.has(tile_pos):
			tile_map.set_cell(tile_pos, 0, Vector2i(4,0))
			map_source[tile_pos] = true
		else:
			if map_source.has(tile_pos):
				map_source.erase(tile_pos)
				tile_map.set_cell(tile_pos, 0, Vector2i(0,0))
	old_tile_pos = tile_pos # Keep old tile position to avoid repeatedly changing it


func _save_map_to_file(filename: String):
	var file := FileAccess.open(SAVE_PATH.path_join(filename), FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % FileAccess.get_open_error())
		return
	file.store_var(map_source)
	file.close()
	populate_presets()
	for index in preset_list.item_count:
		if preset_list.get_item_text(index) == filename:
			preset_list.select(index)
	_set_default()

func get_preset_filenames() -> Array[String]:
	var file_names: Array[String] = []
	
	var dir := DirAccess.open(SAVE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if not dir.current_is_dir(): # Ignore subdirs
				file_names.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to access directory: " + SAVE_PATH)

	return file_names

func populate_presets():
	preset_list.clear()
	for filename in get_preset_filenames():
		preset_list.add_item(filename)
	preset_list.select(0)


func _on_ui_preset_selected(index: int) -> void:
	current_preset = index
	_on_ui_reset()

func load_preset(index: int) -> Dictionary[Vector2i, bool]:

	var _preset: Dictionary[Vector2i, bool] = {}
	var file_name: String = preset_list.get_item_text(index)

	if not FileAccess.file_exists(SAVE_PATH.path_join(file_name)):
		push_warning("Save file does not exist at path: %s" % SAVE_PATH.path_join(file_name))
		return {}

	var file := FileAccess.open(SAVE_PATH.path_join(file_name), FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % FileAccess.get_open_error())
		return {}

	_preset = file.get_var()
	file.close()

	if _preset is Dictionary[Vector2i, bool]:
		return _preset
	
	return {}
