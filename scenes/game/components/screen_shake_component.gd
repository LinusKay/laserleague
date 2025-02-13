extends Node

@export var camera: Camera2D
## Maximum h/v shake in pixels
@export var SHAKE_MAX_OFFSET: Vector2 = Vector2(100, 75)
## Maximum rotation in radians (use sparingly)
@export var SHAKE_MAX_ROLL: float = 0.1
## How quickly the shaking stops
@export var SHAKE_DECAY_RATE: float = 6
## How fast the noise is scrolled through
@export var SHAKE_SPEED: float = 3
## How quickly values change across the noise (scale)
@export var NOISE_FREQUENCY: float = 2
## Starting strength value on _ready()
@export_range(0, 1) var SHAKE_BASE_STRENGTH: float = 0
## Whether or not the intensity automatically decreases over time
@export var auto_decrement_shake: bool = true

# Actual intensity value, goes from 0 to 1
var shake_intensity: float = 0

var rand := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()
var noise_i: float = 0


func _ready() -> void:
	if !camera: push_error("ScreenShakeComponent: camera not assigned!")
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = NOISE_FREQUENCY
	shake_intensity = SHAKE_BASE_STRENGTH


func _process(_delta: float) -> void:
	if !auto_decrement_shake: return
	process_decrement_shake()


func add_shake(amount: float) -> void:
	shake_intensity = min(shake_intensity + amount, 1)


func process_decrement_shake() -> void:
	noise_i += get_process_delta_time() * SHAKE_SPEED
	shake_intensity = lerp(shake_intensity, 0., SHAKE_DECAY_RATE * get_process_delta_time())
	camera.offset = get_random_offset()
	camera.rotation = get_random_rotation_offset()


func get_random_offset() -> Vector2:
	var offset_amount: Vector2 = SHAKE_MAX_OFFSET * shake_intensity
	return Vector2(
		# 1 and 100 are sample points far enough apart so as to not appear similar
		offset_amount.x * noise.get_noise_2d(1, noise_i),
		offset_amount.y * noise.get_noise_2d(100, noise_i)
	)


func get_random_rotation_offset() -> float:
	var roll_amount: float = SHAKE_MAX_ROLL * shake_intensity
	return roll_amount * noise.get_noise_2d(200, noise_i)
