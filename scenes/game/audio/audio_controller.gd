extends AudioStreamPlayer

var vol_tween: Tween = create_tween()
const VOL_INCREASE_HOLD = -5.0
const VOL_INCREASE_RELEASE = 0.0
const VOL_NORM = -50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(volume_db)
	pass



func _on_player_1_attack_start() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_HOLD)

func _on_player_2_attack_start() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_HOLD)

func _on_player_1_attacked() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_RELEASE)

func _on_player_2_attacked() -> void:
	_audio_rise_attack(%AudioSynthArp, VOL_INCREASE_RELEASE)

func _audio_rise_attack(_audio_node: AudioStreamPlayer, _vol_increase: float) -> void:
	#var vol_initial: float = volume_db
	_audio_node.volume_db = _vol_increase
	if vol_tween:
		vol_tween.kill()
	vol_tween = create_tween()
	vol_tween.tween_property(_audio_node, "volume_db", VOL_NORM, 5.0)
	print("audio increase")
	pass
