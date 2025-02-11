## Handles the base movement of an assigned (usually parent) characterbody2d, handling acceleration/direction
# all these are designed to be used in _process()
extends Node
class_name VelocityComponent

@export var max_speed: float = 40
@export var acceleration: float = 5

var velocity: Vector2 = Vector2.ZERO

# accelerate towards a node in the "player" group
func accelerate_to_player() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null: return

	accelerate_to_target(player.global_position)

# accelerate to given target
func accelerate_to_target(target_global_position: Vector2) -> void:
	var owner_node2d: Node2D = owner
	if owner_node2d == null: return
	
	var direction: Vector2 = (target_global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)


# accelerate in given direction
func accelerate_in_direction(direction: Vector2, custom_speed: float = 0) -> void:
	var desired_velocity: Vector2
	if custom_speed:
		desired_velocity = direction * custom_speed
	else:
		desired_velocity = direction * max_speed
	# fi-lerp velocity towards the desired velocity
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))

# slow down
func decelerate() -> void:
	accelerate_in_direction(Vector2.ZERO)

# essentially calling move_and_slide() on the specified body
func move(character_body: CharacterBody2D) -> void:
	# set body velocity to desired value, then slide, 
	character_body.velocity = velocity
	character_body.move_and_slide()
	# then set velocity to the resulting body velocity after sliding
	# this just makes sure they're always the same
	velocity = character_body.velocity
