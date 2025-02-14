extends Node

var vol_tween: Tween
const VOL_LERP_RATE: float = 0.2

#region SFX
# general
@onready var SFX_START: Resource = load("res://assets/sounds/sfx/sfx_start.ogg")
@onready var music_base: AudioStreamPlayer = %MusicBase
@onready var music_arp: AudioStreamPlayer = %MusicArp
@onready var music_synth: AudioStreamPlayer = %MusicSynth

# player
@onready var SFX_DASH: Resource = load("res://assets/sounds/sfx/sfx_dash.ogg")
@onready var SFX_DIED: Resource = load("res://assets/sounds/sfx/sfx_dash.ogg")
@onready var SFX_WIN: Resource = load("res://assets/sounds/sfx/sfx_win.ogg")
@onready var SFX_HIT: Resource = load("res://assets/sounds/sfx/sfx_hit.ogg")
@onready var SFX_MISS: Resource = load("res://assets/sounds/sfx/sfx_miss.ogg")
@onready var SFX_CHARGE: Resource = load("res://assets/sounds/sfx/sfx_charge.ogg")
@onready var SFX_SHOOT_BIG: Resource = load("res://assets/sounds/sfx/sfx_shoot_big.ogg")
@onready var SFX_SHOOT_MED: Resource = load("res://assets/sounds/sfx/sfx_shoot_med.ogg")
@onready var SFX_SHOOT_SMALL: Resource = load("res://assets/sounds/sfx/sfx_shoot_small.ogg")
#endregion

const SFX_PLAYER = preload("res://scenes/game/audio/sfx_player.tscn")
const SPOT_SFX_PLAYER = preload("res://scenes/game/audio/spot_sfx_player.tscn")



func _ready() -> void:
	Global.player_attack_charging.connect(on_player_attack_charging)
	Global.player_attack_released.connect(on_player_attack_released)


func play_sfx(_sfx_file: Resource, pitch_random: float = 0.1, volume: float = 1) -> void:
	var sfx_player_instance: AudioStreamPlayer = SFX_PLAYER.instantiate()
	add_child(sfx_player_instance)
	
	sfx_player_instance.stream = _sfx_file
	sfx_player_instance.pitch_scale += randf_range(-pitch_random, pitch_random)
	sfx_player_instance.volume_db = linear_to_db(volume)
	sfx_player_instance.play()

# unused
func play_spot_sfx(_sfx_file: Resource, global_position: Vector2, pitch_random: float = 0.2) -> void:
	var sfx_player_instance: AudioStreamPlayer2D
	sfx_player_instance = SPOT_SFX_PLAYER.instantiate()
	add_child(sfx_player_instance)
	sfx_player_instance.global_position = global_position
	sfx_player_instance.stream = _sfx_file
	sfx_player_instance.pitch_scale += randf_range(-pitch_random, pitch_random)


func on_player_attack_charging(player_index: int, strength: float) -> void:
	if player_index == 0:
		music_arp.volume_db = lerp(music_arp.volume_db, linear_to_db(clampf(strength, 0, 1)), VOL_LERP_RATE)
	elif player_index == 1:
		music_synth.volume_db = lerp(music_synth.volume_db, linear_to_db(clampf(strength, 0, 1)), VOL_LERP_RATE)


var music_arp_vol_tween: Tween
var music_synth_vol_tween: Tween

func on_player_attack_released(player_index: int) -> void:
	if player_index == 0:
		if music_arp_vol_tween and music_arp_vol_tween.is_running(): music_arp_vol_tween.kill()
		music_arp_vol_tween = create_tween()
		music_arp_vol_tween.tween_property(music_arp, "volume_db", linear_to_db(.001), .3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	elif player_index == 1:
		if music_synth_vol_tween and music_synth_vol_tween.is_running(): music_synth_vol_tween.kill()
		music_synth_vol_tween = create_tween()
		music_synth_vol_tween.tween_property(music_synth, "volume_db", linear_to_db(.001), .3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


#func audio_rise_attack(_audio_node: AudioStreamPlayer, _vol_increase: float, _vol_decrease_seconds: float = 5.0) -> void:
	##print("VOl Decrease Seconds: " + str(_vol_decrease_seconds))
	#_audio_node.volume_db = _vol_increase
	#if vol_tween and vol_tween.is_running(): 
		#vol_tween.kill()
	#vol_tween = create_tween()
	#vol_tween.tween_property(_audio_node, "volume_db", VOL_NORM, _vol_decrease_seconds)
