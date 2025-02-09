extends Control
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var pause_menu_contents: MarginContainer = %PauseMenuContents


func _ready() -> void:
	resume_button.pressed.connect(on_resume_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	settings_menu.visible = false
	visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !get_tree().paused:
			pause()
		else:
			unpause()


func pause() -> void:
	get_tree().paused = true
	visible = true


func unpause() -> void:
	visible = false
	get_tree().paused = false


func on_resume_button_pressed() -> void:
	unpause()


func on_settings_button_pressed() -> void:
	pause_menu_contents.visible = false
	settings_menu.visible = true


func settings_back_button_pressed() -> void:
	pause_menu_contents.visible = true
	settings_menu.visible = false


func on_quit_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
