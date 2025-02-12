extends AudioStreamPlayer

var vol_tween: Tween = create_tween()
const VOL_INCREASE_HOLD = -15.0
const VOL_INCREASE_RELEASE = 0.0
const VOL_NORM = -50.0


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
	if vol_tween:
		vol_tween.kill()
	vol_tween = create_tween()
	vol_tween.tween_property(_audio_node, "volume_db", VOL_NORM, _vol_decrease_seconds)
	pass
