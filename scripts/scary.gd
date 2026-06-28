extends Sprite3D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _on_player_entered() -> void:
	animation.play("Scare_ani")
	await animation.animation_finished
	queue_free()
