extends Camera2D

@export var target: Node2D = null
@export var screen_shake_amount: float = 0.0
@export var screen_shake_decay_rate: float = 1.0
@export var max_screen_shake: float = 200
var screen_shake_offset: Vector2 = Vector2(0.0, 0.0)
@export var screen_shake_interval: float = 0.05

@onready var camera: Camera2D = self
var camera_offset: Vector2 = Vector2.ZERO

var screen_shake_current: float = screen_shake_interval


func _ready() -> void:
	if camera == null: push_error("ScreenShake: Camera not assigned!")
	Global.add_screen_shake_signal.connect(on_add_screen_shake_signal)


func _process(delta: float) -> void:
	process_screen_shake()


func add_screen_shake(amount: float) -> void:
	if screen_shake_current <= max_screen_shake:
		screen_shake_current += amount
	if screen_shake_current > max_screen_shake:
		screen_shake_current = max_screen_shake


func process_screen_shake() -> void:
	screen_shake_current -= get_process_delta_time() * screen_shake_decay_rate
	
	if screen_shake_current > 0:
		screen_shake_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		#screen_shake_current = screen_shake_interval
		var shake: Vector2 = screen_shake_offset * screen_shake_amount * screen_shake_current
		
		if target != null:
			camera.global_position = lerp(camera.global_position, target.global_position + Vector2(camera_offset.x, camera_offset.y), 0.3) + Vector2(shake.x, shake.y)
	else:
		screen_shake_current = 0 

func on_add_screen_shake_signal(amount: float) -> void:
	add_screen_shake(amount)
