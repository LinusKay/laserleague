## Autoload for sending/storing data throughout disparate parts of the scene tree
extends Node

# Any script can call Global.emit_example() to send, or Global.example.connect(on_example) to receive
signal example
func emit_example() -> void: example.emit()

signal add_screen_shake(amount: float)
func emit_add_screen_shake(amount: float) -> void: add_screen_shake.emit(amount)
