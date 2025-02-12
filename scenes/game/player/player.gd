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

const ATTACK_SPRITE_Y_BASE = 0.594
const ATTACK_INDICATOR_SPRITE_Y_BASE = 0.094
const ATTACK_SPRITE_Y_INCREASE = 0.005
const ATTACK_POWER_BASE = 1.0
const ATTACK_POWER_INCREASE = 0.01

var last_targeted_rotation: Vector2
var is_attacking: bool = false
var is_charging: bool = false

var attack_power: float = ATTACK_POWER_BASE

signal attacked(attack_power: float)
signal attack_start

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
	
	if Input.is_action_pressed("attack") and !is_attacking:
		if !is_charging: emit_signal("attack_start")
		is_charging = true
		attack_power += ATTACK_POWER_INCREASE
		%AttackSprite.scale.y += ATTACK_SPRITE_Y_INCREASE
		%AttackIndicatorSprite.scale.y += ATTACK_SPRITE_Y_INCREASE
		print("----------Attack Charge----------"\
		+ "\nAttack Power: " + str(attack_power)
		+ "\nAttack Sprite Scale: " + str(%AttackSprite.scale.y)
		+ "\nAttack Indicator Sprite Scale: " + str(%AttackIndicatorSprite.scale.y)
		)
	if Input.is_action_just_released("attack") and !is_attacking:
		attack()


func attack() -> void:
	print("----------Attack Released!----------"\
	+ "\nAttack Power: " + str(attack_power)
	+ "\nAttack Sprite Scale: " + str(%AttackSprite.scale.y)
	+ "\nAttack Indicator Sprite Scale: " + str(%AttackIndicatorSprite.scale.y)
	)
	animation_player.play("attack")
	emit_signal("attacked", attack_power)
	attack_screen_shake()
	await animation_player.animation_finished
	is_attacking = false
	is_charging = false
	%AttackSprite.scale.y = ATTACK_SPRITE_Y_BASE
	%AttackIndicatorSprite.scale.y = ATTACK_INDICATOR_SPRITE_Y_BASE
	attack_power = ATTACK_POWER_BASE


func attack_screen_shake() -> void:
	Global.add_screen_shake(1)
