extends CharacterBody2D

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var attack_hitbox_component: HitboxComponent = %AttackHitboxComponent

@export var are_controls_active: bool = true

@export_flags_2d_physics var hurt_collision_mask: int
@export_flags_2d_physics var attack_hit_collision_layer: int

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var last_targeted_rotation: Vector2
var is_attacking: bool = false


func _ready() -> void:
	hurtbox_component.collision_layer = hurt_collision_mask
	attack_hitbox_component.collision_layer = attack_hit_collision_layer


func _process(delta: float) -> void:
	
	if !are_controls_active: return
	velocity_component.accelerate_in_direction(Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized())
	velocity_component.move(self)
	
	var is_aiming: bool = Input.is_action_pressed("aim_left") or Input.is_action_pressed("aim_right") or Input.is_action_pressed("aim_up") or Input.is_action_pressed("aim_down")
	if is_aiming:
		last_targeted_rotation = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_up", "aim_down"))
		rotation_component.rotate_towards_position(last_targeted_rotation.normalized(), self)
	
	if Input.is_action_just_released("attack") and !is_attacking:
		attack()


func attack() -> void:
	animation_player.play("attack")
	await animation_player.animation_finished
	is_attacking = false


func attack_screen_shake() -> void:
	Global.add_screen_shake(1)
