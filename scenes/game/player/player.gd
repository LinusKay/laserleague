extends CharacterBody2D

@onready var velocity_component: VelocityComponent = %VelocityComponent

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	velocity_component.accelerate_in_direction(Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized())
	velocity_component.move(self)
