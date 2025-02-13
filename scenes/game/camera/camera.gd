extends Camera2D

@onready var screen_shake_component: Node = %ScreenShakeComponent


func _ready() -> void:
	Global.add_screen_shake_signal.connect(on_add_screen_shake_signal)


func on_add_screen_shake_signal(amount: float) -> void:
	screen_shake_component.add_shake(amount)
