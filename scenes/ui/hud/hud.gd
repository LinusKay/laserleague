extends Control

@onready var player_a_charge_bar: TextureProgressBar = %PlayerAChargeBar
@onready var player_b_charge_bar: TextureProgressBar = %PlayerBChargeBar
@onready var player_a_health_bar: TextureProgressBar = %PlayerAHealthBar
@onready var player_b_health_bar: TextureProgressBar = %PlayerBHealthBar
@onready var win_animation_player: AnimationPlayer = %WinAnimationPlayer

@export var player_a: Player
@export var player_b: Player


func _ready() -> void:
	Global.player_won_round.connect(on_player_won_round)
	%WinLabelA.visible = false
	%WinLabelB.visible = false
	update_scores()
	
	if ScoreManager.scores == [ 0, 0 ]:
		%TutorialLabel.visible = true
	else:
		%TutorialLabel.visible = false


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


func update_scores() -> void:
	# update labels based on ScoreManager array
	%ScoreLabelA.text = str(ScoreManager.scores[0])
	%ScoreLabelB.text = str(ScoreManager.scores[1])


func on_player_won_round(player_index: int) -> void:
	# show relevant label for winner
	match player_index:
		0:
			%WinLabelA.visible = true
		1:
			%WinLabelB.visible = true
		_: push_error("HUD: Specified player doesn't exist!")
	update_scores()
	win_animation_player.play("win")
	await win_animation_player.animation_finished
	%WinLabelA.visible = false
	%WinLabelB.visible = false
	# reload scene for new round
	ScreenTransition.transition_to_scene("res://scenes/game/main.tscn")
