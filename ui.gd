extends CanvasLayer

var file_name: String = "" # hold the user's input

@onready var cycles_label = $MarginContainer4/Cycles

@onready var popup: ConfirmationDialog = $ConfirmationDialog
@onready var input_field: LineEdit = $ConfirmationDialog/LineEdit

signal start_stop_toggle()
signal step()
signal reset()
signal save_as()
signal preset_selected()

func start_stop():
	start_stop_toggle.emit()


func step_pressed():
	step.emit() 


func _on_reset_pressed() -> void:
	reset.emit()


func _on_main_cycle(count) -> void:
	cycles_label.text = str(count)


func _on_save_as_pressed() -> void:
	open_input_popup()

func _ready() -> void:
	popup.confirmed.connect(_on_popup_confirmed)
	input_field.text_submitted.connect(_on_text_submitted)


func open_input_popup() -> void:
	input_field.clear()      # Clear old text
	popup.popup_centered()
	input_field.grab_focus() # focus the text box

# User clicks "OK"
func _on_popup_confirmed() -> void:
	_save_and_close()

# User hits "Enter" while typing
func _on_text_submitted(_new_text: String) -> void:
	_save_and_close()

func _save_and_close() -> void:
	file_name = input_field.text
	popup.hide() 
	save_as.emit(file_name)


func _on_presets_item_selected(index: int) -> void:
	preset_selected.emit(index)
