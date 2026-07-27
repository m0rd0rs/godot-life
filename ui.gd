extends CanvasLayer

signal start_stop_toggle()
signal step()

func start_stop():
	start_stop_toggle.emit()

func step_pressed():
	step.emit() 
