extends Control

@onready var player_a_charge_bar: TextureProgressBar = %PlayerAChargeBar
@onready var player_b_charge_bar: TextureProgressBar = %PlayerBChargeBar
@onready var player_a_health_bar: TextureProgressBar = %PlayerAHealthBar
@onready var player_b_health_bar: TextureProgressBar = %PlayerBHealthBar

@export var player_a: Player
@export var player_b: Player


func _process(_delta: float) -> void:
	if player_a != null:
		var charge_target_value: float = clampf(player_a.attack_power, 0, 1)
		player_a_charge_bar.value = lerpf(player_a_charge_bar.value, charge_target_value, 0.2)
		var health_target_value: float = player_a.health_component.current_health
		player_a_health_bar.value = lerpf(player_a_health_bar.value, health_target_value, 0.6)
	else:
		player_a_health_bar.value = 0
	if player_b != null:
		var charge_target_value: float = clampf(player_b.attack_power, 0, 1)
		player_b_charge_bar.value = lerpf(player_b_charge_bar.value, charge_target_value, 0.2)
		var health_target_value: float = player_b.health_component.current_health
		player_b_health_bar.value = lerpf(player_b_health_bar.value, health_target_value, 0.6)
	else:
		player_b_health_bar.value = 0
	
	
