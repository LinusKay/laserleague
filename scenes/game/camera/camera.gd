extends Camera2D

@export var screen_shake_decay_rate: float = 1.0
@export var max_screen_shake: float = 200
var screen_shake_offset: Vector2 = Vector2(0.0, 0.0)
@export var screen_shake_interval: float = 0.05

@export var target: Node2D = null
@export var decay: float = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset: Vector2 = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
@export var max_roll: float = 0.1  # Maximum rotation in radians (use sparingly).

@onready var camera: Camera2D = self
var camera_offset: Vector2 = Vector2.ZERO

var screen_shake_current: float = screen_shake_interval


func _ready() -> void:
	Global.add_screen_shake_signal.connect(on_add_screen_shake_signal)


func _process(_delta: float) -> void:
	process_screen_shake()


func add_screen_shake(amount: float) -> void:
	print("total " + str(screen_shake_current) + " screenshake")
	if screen_shake_current <= max_screen_shake:
		screen_shake_current += amount
	if screen_shake_current > max_screen_shake:
		screen_shake_current = max_screen_shake


func process_screen_shake() -> void:
	pass

func on_add_screen_shake_signal(amount: float) -> void:
	add_screen_shake(amount)
