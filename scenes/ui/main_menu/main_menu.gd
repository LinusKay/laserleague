extends Control
class_name MainMenu

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

const main_scene_path: String = "res://scenes/game/main.tscn"
const settings_scene_path: String = "res://scenes/ui/main_menu/settings_main_menu.tscn"


func _ready() -> void:
	play_button.pressed.connect(on_play_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)


func on_play_button_pressed() -> void:
	ScreenTransition.transition_to_scene(main_scene_path)


func on_settings_button_pressed() -> void:
	ScreenTransition.transition_to_scene(settings_scene_path)


func on_quit_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().quit()
