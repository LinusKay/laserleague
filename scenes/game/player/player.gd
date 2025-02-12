@tool
extends CharacterBody2D
class_name Player

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var attack_hitbox_component: HitboxComponent = %AttackHitboxComponent
@onready var layer_fx: Node2D = get_tree().get_first_node_in_group("LayerFX")

@export var player_name: String = "Player"
@export var are_controls_active: bool = true
## Set this to RAW >1 for glow!
@export var player_color: Color = Color.WHITE
@export var player_attack_color: Color = Color.WHITE
@export var player_attack_ind_color: Color = Color.WHITE

@export_flags_2d_physics var hurt_collision_mask: int
@export_flags_2d_physics var attack_hit_collision_layer: int
@export var death_particle_scene: PackedScene

const ATTACK_SPRITE_Y_BASE = 0.05
const ATTACK_INDICATOR_SPRITE_Y_BASE = 0.094
const ATTACK_SPRITE_SCALE_INCREASE = 0.004
const ATTACK_HITBOX_SCALE_INCREASE = 0.005
const ATTACK_POWER_BASE = 0.01
const SECONDS_UNTIL_MAX_DAMAGE = 5
const ROTATION_ACCELERATION_BASE = 1
const ROTATION_ACCELERATION_DECREASE = .01
const VELOCITY_DECREASE = .005


var last_targeted_rotation: Vector2
var is_attacking: bool = false
var is_charging: bool = false

var attack_power: float = ATTACK_POWER_BASE

signal attacked(attack_power: float)
signal attack_start

func _ready() -> void:
	velocity_component.reset_speed()
	if Engine.is_editor_hint(): return
	%PlayerSprite.modulate = player_color
	%AttackSpriteHead.modulate = player_attack_color
	%AttackSprite.modulate = player_attack_color
	%AttackIndicatorSprite.modulate = player_attack_ind_color
	
	hurtbox_component.collision_layer = hurt_collision_mask
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
	velocity_component.accelerate_in_direction(Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized())
	velocity_component.move(self)
	
	var is_aiming: bool = Input.is_action_pressed("aim_left") or Input.is_action_pressed("aim_right") or Input.is_action_pressed("aim_up") or Input.is_action_pressed("aim_down")
	if is_aiming:
		if !is_attacking:
			last_targeted_rotation = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_up", "aim_down"))
			rotation_component.rotate_towards_position(last_targeted_rotation.normalized(), self)
		#else:
			#last_targeted_rotation = Vector2.RIGHT.rotated(rotation)
	
	if Input.is_action_pressed("attack") and !is_attacking:
		if !is_charging: emit_signal("attack_start")
		is_charging = true
		attack_power += get_process_delta_time() / SECONDS_UNTIL_MAX_DAMAGE
		%AttackSprite.scale.y += ATTACK_SPRITE_SCALE_INCREASE
		%AttackSpriteHead.scale += Vector2(ATTACK_SPRITE_SCALE_INCREASE, ATTACK_SPRITE_SCALE_INCREASE) * 0.35
		%AttackIndicatorSprite.scale.y += ATTACK_SPRITE_SCALE_INCREASE
		%AttackHitboxComponent.scale.y += ATTACK_HITBOX_SCALE_INCREASE
		#print("----------Attack Charge----------"\
		#+ "\nAttack Power: " + str(attack_power)
		#+ "\nAttack Sprite Scale: " + str(%AttackSprite.scale.y)
		#+ "\nAttack Indicator Sprite Scale: " + str(%AttackIndicatorSprite.scale.y)
		#)
		velocity_component.speed *= 1 - VELOCITY_DECREASE
		rotation_component.acceleration *= 1 - ROTATION_ACCELERATION_DECREASE
		
	if Input.is_action_just_released("attack") and !is_attacking:
		attack()
		var bounce_direction := -transform.x.normalized() 
		var bounce_speed := 5000 * attack_power 
		velocity_component.accelerate_in_direction(bounce_direction, bounce_speed)


func attack() -> void:
	if Engine.is_editor_hint(): return
	print("----------Attack Released!----------"\
	+ "\nAttack Power: " + str(attack_power)
	+ "\nAttack Sprite Scale: " + str(%AttackSprite.scale.y)
	+ "\nAttack Indicator Sprite Scale: " + str(%AttackIndicatorSprite.scale.y)
	)
	attack_hitbox_component.damage = attack_power
	animation_player.play("attack")
	emit_signal("attacked", attack_power)
	attack_screen_shake()
	is_attacking = true
	await animation_player.animation_finished
	is_attacking = false
	is_charging = false
	%AttackSprite.scale.y = ATTACK_SPRITE_Y_BASE
	%AttackSpriteHead.scale = Vector2(ATTACK_SPRITE_Y_BASE, ATTACK_SPRITE_Y_BASE)
	%AttackIndicatorSprite.scale.y = ATTACK_INDICATOR_SPRITE_Y_BASE
	%AttackHitboxComponent.scale = Vector2.ONE
	attack_power = ATTACK_POWER_BASE
	velocity_component.reset_speed()
	rotation_component.acceleration = ROTATION_ACCELERATION_BASE


func attack_screen_shake() -> void:
	if Engine.is_editor_hint(): return
	Global.add_screen_shake(100)


func on_died() -> void:
	print(player_name + " died!")
	var death_particle_instance: GPUParticles2D = death_particle_scene.instantiate()
	if layer_fx: layer_fx.add_child(death_particle_instance)
	death_particle_instance.global_position = global_position
	death_particle_instance.modulate = player_attack_color
	queue_free()
	
