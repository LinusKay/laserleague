## Autoload for sending/storing data throughout disparate parts of the scene tree
extends Node

# Any script can call Global.emit_example() to send, or Global.example.connect(on_example) to receive
signal example
func emit_example() -> void: example.emit()

signal player_won_round(player_index: int)
func emit_player_won_round(player_index: int) -> void: player_won_round.emit(player_index)

signal add_screen_shake_signal(amount: float)
func add_screen_shake(amount: float) -> void: add_screen_shake_signal.emit(amount)

# global inputs
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_fullscreen"):
		toggle_fullscreen()
	if Input.is_action_just_pressed("reset_score"):
		ScoreManager.scores = [ 0, 0 ]
		ScreenTransition.transition_to_scene("res://scenes/game/main.tscn")


func toggle_fullscreen() -> void:
	var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
