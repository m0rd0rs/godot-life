extends CanvasLayer

@onready var cycles_label = $MarginContainer4/Cycles

signal start_stop_toggle()
signal step()
signal reset()

func start_stop():
	start_stop_toggle.emit()


func step_pressed():
	step.emit() 


func _on_reset_pressed() -> void:
	reset.emit()


func _on_main_cycle(count) -> void:
	cycles_label.text = str(count)
