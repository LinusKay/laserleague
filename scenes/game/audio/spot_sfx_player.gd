extends AudioStreamPlayer2D


func _ready() -> void:
	await finished
	queue_free()
