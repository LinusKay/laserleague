extends Control

@onready var player_a_charge_bar: TextureProgressBar = %PlayerAChargeBar
@onready var player_b_charge_bar: TextureProgressBar = %PlayerBChargeBar

@export var player_a: Player
@export var player_b: Player


func _process(delta: float) -> void:
	if player_a != null:
		var target_value: float = clampf(player_a.attack_power, 0, 1)
		player_a_charge_bar.value = lerpf(player_a_charge_bar.value, target_value, 0.2)
	if player_b != null:
		var target_value: float = clampf(player_b.attack_power, 0, 1)
		player_b_charge_bar.value = lerpf(player_b_charge_bar.value, target_value, 0.2)
