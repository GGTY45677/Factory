extends Area3D

signal picked_up

func Interact():
	emit_signal("picked_up")
	queue_free()
