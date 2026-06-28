extends Control

@onready var Line: LineEdit = $LineEdit

func _process(delta: float) -> void:
	if Line.text == "LIGHT":
		print("WOW")
