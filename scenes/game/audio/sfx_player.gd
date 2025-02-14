extends AudioStreamPlayer


func _ready() -> void:
	await finished
	queue_free()
