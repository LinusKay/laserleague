extends Control
class_name SettingsMenu

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var window_button: Button = %WindowButton
@onready var back_button: Button = %BackButton

@export var is_pause_menu_settings: bool = false
@export var pause_menu: Control


func _ready() -> void:
	handle_signals()
	update_display()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		exit_settings_menu()


func exit_settings_menu() -> void:
	if is_pause_menu_settings: 
		pause_menu.settings_back_button_pressed()
	else:
		ScreenTransition.transition_to_scene("res://scenes/ui/main_menu/main_menu.tscn")


func on_back_button_pressed() -> void:
	exit_settings_menu()


func on_window_button_pressed() -> void:
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()


func update_display() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	else:
		window_button.text = "Windowed"
	# If you're getting an error here you need to add the sfx and music buses
	sfx_volume_slider.value = get_bus_volume_percent("Master")
	sfx_volume_slider.value = get_bus_volume_percent("sfx")
	music_volume_slider.value = get_bus_volume_percent("music")
	

func get_bus_volume_percent(bus_name: String) -> float:
	var volume_db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	return db_to_linear(volume_db)


func on_audio_slider_changed(value: float, bus_name: String) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value))



func handle_signals() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	window_button.pressed.connect(on_window_button_pressed)
	master_volume_slider.value_changed.connect(on_audio_slider_changed.bind("Master"))
	sfx_volume_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_volume_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
