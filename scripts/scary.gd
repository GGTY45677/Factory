extends Sprite3D

func _on_player_entered() -> void:
	queue_free()
	print("disappeared")
