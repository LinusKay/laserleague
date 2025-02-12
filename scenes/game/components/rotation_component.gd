extends Node
class_name RotationComponent

@onready var target: Node2D = %Target

@export var max_rotation_speed: float = 10
@export var acceleration: float = 1:
	set(value):
		acceleration = max(0, value)


func rotate_towards_position(target_position: Vector2, node: Node2D) -> void:
	target.look_at(target_position)
	rotate_towards_angle(target.rotation, node)


func rotate_towards_angle(angle_rad: float, node: Node2D) -> void:
	var angle_diff: float = angle_difference(node.rotation, angle_rad)
	var target_rotation_amount: float = clamp(1, 0, abs(angle_diff)) * sign(angle_diff)
	node.rotation = lerpf(node.rotation, target_rotation_amount * max_rotation_speed, 1 - exp(-acceleration * get_process_delta_time()))
