@tool
extends CharacterBody2D
class_name Player

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer
@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var attack_hitbox_component: HitboxComponent = %AttackHitboxComponent
@onready var layer_fx: Node2D = get_tree().get_first_node_in_group("LayerFX")

@onready var sfx_dash: Resource = load("res://assets/sounds/sfx/sfx_dash.ogg")
@onready var sfx_died: Resource = load("res://assets/sounds/sfx/sfx_dash.ogg")
@onready var sfx_win: Resource = load("res://assets/sounds/sfx/sfx_win.ogg")
@onready var sfx_hit: Resource = load("res://assets/sounds/sfx/sfx_hit.ogg")
@onready var sfx_miss: Resource = load("res://assets/sounds/sfx/sfx_miss.ogg")

@export var audio_controller: AudioStreamPlayer

@export var player_index: int
@export var player_name: String = "Player"
@export var are_controls_active: bool = true
## Set this to RAW >1 for glow!
@export var player_color: Color = Color.WHITE
@export var player_attack_color: Color = Color.WHITE
@export var player_attack_ind_color: Color = Color.WHITE
@export var hp_pulse_color: Color = Color.RED

@export var controller_id: int = 0

@export_flags_2d_physics var hurt_collision_mask: int
@export_flags_2d_physics var attack_hit_collision_layer: int
@export var death_particle_scene: PackedScene

const ATTACK_SPRITE_Y_BASE = 0.05
const ATTACK_INDICATOR_SPRITE_Y_BASE = 0.094
const ATTACK_SPRITE_SCALE_INCREASE = 1.0
const ATTACK_HITBOX_SCALE_INCREASE = 1.5
const ATTACK_POWER_BASE = 0.01
const SECONDS_UNTIL_MAX_DAMAGE = 5.0
const ROTATION_ACCELERATION_BASE = 1.0
const ROTATION_ACCELERATION_DECREASE = 0.5
const VELOCITY_DECREASE = 0.5
const DASH_STRENGTH = 30
const DASH_DECREASE_SCALE = 3.5
const CHARGE_SELF_DAMAGE = 0.01

const JOY_DEADZONE = 0.2

var last_targeted_rotation: Vector2
var is_attacking: bool = false
var is_charging: bool = false
var is_dashing: bool = false

var attack_hit: bool = false

var attack_power: float = ATTACK_POWER_BASE

var hp_tween: Tween
var health_pulse_threshold: float = 0.4

signal attacked(attack_power: float)
signal attack_start


func _ready() -> void:
	velocity_component.reset_speed()
	if Engine.is_editor_hint(): return
	%PlayerSprite.modulate = player_color
	%AttackSpriteHead.modulate = player_attack_color
	%AttackSprite.modulate = player_attack_color
	%AttackIndicatorSprite.modulate = player_attack_ind_color
	
	hurtbox_component.collision_mask = hurt_collision_mask
	attack_hitbox_component.collision_layer = attack_hit_collision_layer

	health_component.died.connect(on_died)


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): 
		%PlayerSprite.modulate = player_color
		%AttackSpriteHead.modulate = player_attack_color
		%AttackSprite.modulate = player_attack_color
		%AttackIndicatorSprite.modulate = player_attack_ind_color
		return
		
	if !are_controls_active: return
	
	# Left stick movement
	var move_input: Vector2 = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y),
	)
	if is_dashing: move_input = Vector2.ZERO
	if abs(move_input.x) < JOY_DEADZONE:
		move_input.x = 0.0
	if abs(move_input.y) < JOY_DEADZONE:
		move_input.y = 0.0
			
	velocity_component.accelerate_in_direction(move_input)
	velocity_component.move(self)
	
	if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_LEFT_SHOULDER) and !is_dashing:
		dash("left")
	if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_RIGHT_SHOULDER) and !is_dashing:
		dash("right")
	
	# Right stick aiming
	var aim_input: Vector2 = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X), 
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y)
	)
	if aim_input.length() < JOY_DEADZONE:
		aim_input = Vector2.ZERO
	var is_aiming: bool = aim_input != Vector2.ZERO
	if is_aiming:
		if !is_attacking:
			last_targeted_rotation = aim_input.normalized()
			rotation_component.rotate_towards_position(last_targeted_rotation, self)
	
	# Get trigger inputs
	var trigger_left: bool = abs(Input.get_joy_axis(controller_id, JOY_AXIS_TRIGGER_LEFT)) > JOY_DEADZONE
	var trigger_right: bool = abs(Input.get_joy_axis(controller_id, JOY_AXIS_TRIGGER_RIGHT)) > JOY_DEADZONE

	# If either trigger is held and not currently attacking, initiate attack charge
	var attack_input: bool = trigger_left or trigger_right
	if attack_input and !is_attacking:
		if !is_charging: emit_signal("attack_start")
		is_charging = true
		attack_power += get_process_delta_time() / SECONDS_UNTIL_MAX_DAMAGE
		if attack_power > 1: health_component.damage(CHARGE_SELF_DAMAGE)
		%AttackSprite.scale.y += ATTACK_SPRITE_SCALE_INCREASE * delta
		%AttackSpriteHead.scale += Vector2(ATTACK_SPRITE_SCALE_INCREASE, ATTACK_SPRITE_SCALE_INCREASE) * 0.35 * delta
		%AttackIndicatorSprite.scale.y += ATTACK_SPRITE_SCALE_INCREASE * delta
		%AttackHitboxComponent.scale.y += ATTACK_HITBOX_SCALE_INCREASE * delta
		velocity_component.speed *= 1 - VELOCITY_DECREASE * delta
		rotation_component.acceleration *= 1 - ROTATION_ACCELERATION_DECREASE * delta
	
	# If either trigger is not held but meant to be charging, and not already attacking, release attack
	if is_charging and !attack_input and !is_attacking:
		attack()
		bounce_back()
	
	# if health is below threshold, pulse color
	pulse_low_health()


func attack() -> void:
	if Engine.is_editor_hint(): return
	attack_hitbox_component.damage = attack_power
	attack_animation_player.play("attack")
	emit_signal("attacked", attack_power)
	Global.add_screen_shake(attack_power / 2)
	is_attacking = true
	
	await attack_animation_player.animation_finished
	is_attacking = false
	is_charging = false
	%AttackSprite.scale.y = ATTACK_SPRITE_Y_BASE
	%AttackSpriteHead.scale = Vector2(ATTACK_SPRITE_Y_BASE, ATTACK_SPRITE_Y_BASE)
	%AttackIndicatorSprite.scale.y = ATTACK_INDICATOR_SPRITE_Y_BASE
	%AttackHitboxComponent.scale = Vector2.ONE
	attack_power = ATTACK_POWER_BASE
	velocity_component.reset_speed()
	rotation_component.acceleration = ROTATION_ACCELERATION_BASE
	# But of a makeshift solution - is delayed since waiting for animation to complete
	# If outside await then attack_hit doesnt update in time
	if attack_hit: audio_controller.play_sfx(sfx_hit)
	else: audio_controller.play_sfx(sfx_miss)
	attack_hit = false

func on_died() -> void:
	audio_controller.play_sfx(sfx_died)
	audio_controller.play_sfx(sfx_win)
	print(player_name + " died!")
	match player_index:
		0:
			ScoreManager.add_score(1)
		1:
			ScoreManager.add_score(0)
		_: return
	
	if !layer_fx: push_error("Player: layer_fx not found!"); return
	
	var death_particle_instance: GPUParticles2D = death_particle_scene.instantiate()
	layer_fx.add_child(death_particle_instance)
	death_particle_instance.global_position = global_position
	death_particle_instance.modulate = player_attack_color
	
	queue_free()


func bounce_back() -> void:
	var bounce_direction := -transform.x.normalized() 
	var bounce_speed := 5000 * attack_power 
	velocity_component.accelerate_in_direction(bounce_direction, bounce_speed)


func dash(_direction: String) -> void:
	audio_controller.play_sfx(sfx_died)
	is_dashing = true
	var dash_direction: Vector2 = Vector2.ZERO
	#print(transform.y.x)
	if _direction == "left":
		dash_direction = -transform.y.normalized()
	else:
		dash_direction = transform.y.normalized()
	var dash_speed := (DASH_STRENGTH * 1000) / (1 + (attack_power * DASH_DECREASE_SCALE))
	velocity_component.accelerate_in_direction(dash_direction, dash_speed)
	%DashCooldownTimer.start()


func pulse_low_health() -> void:
	if health_component.current_health > health_pulse_threshold: return
	if hp_tween and hp_tween.is_running(): return
	var delay: float = health_component.current_health + 0.05
	hp_tween = create_tween()
	hp_tween.tween_property(self, "modulate", hp_pulse_color, delay)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hp_tween.tween_property(self, "modulate", Color.WHITE, delay)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_dash_cooldown_timer_timeout() -> void:
	is_dashing = false
