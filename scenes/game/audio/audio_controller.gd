extends AudioStreamPlayer

var vol_tween: Tween
const VOL_INCREASE_HOLD = -15.0
const VOL_INCREASE_RELEASE = 0.0
const VOL_NORM = -50.0

@onready var sfx_start: Resource = load("res://assets/sounds/sfx/sfx_start.ogg")

func _ready() -> void:
	play_sfx(sfx_start)

func play_sfx(_sfx_file: Resource) -> void:
	var audio_node: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = _sfx_file
	audio_node.play()
	await audio_node.finished
	audio_node.queue_free()

func _on_player_1_attack_start() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_HOLD, 30.0)

func _on_player_2_attack_start() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_HOLD, 30.0)

func _on_player_1_attacked(attack_power: float) -> void:
	#print("AudioController: Attack Power: " + str(attack_power))
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_RELEASE, attack_power * 2)
	
func _on_player_2_attacked(attack_power: float) -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_RELEASE, attack_power * 2)

func _audio_rise_attack(_audio_node: AudioStreamPlayer, _vol_increase: float, _vol_decrease_seconds: float = 5.0) -> void:
	#print("VOl Decrease Seconds: " + str(_vol_decrease_seconds))
	_audio_node.volume_db = _vol_increase
	if vol_tween and vol_tween.is_running(): 
		vol_tween.kill()
	vol_tween = create_tween()
	vol_tween.tween_property(_audio_node, "volume_db", VOL_NORM, _vol_decrease_seconds)
	pass
