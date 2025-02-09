## Call ScreenTransition.transition_to_scene("res://scene_path...") from anywhere for a nice fade transition!
extends CanvasLayer

enum Types { FADE, CIRCLE_ZOOM }

signal transitioned_halfway

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var skip_emit: bool = false


func transition(type: Types = Types.FADE) -> void:
	var anim_string: String
	match type:
		Types.FADE:
			anim_string = "fade"
		Types.CIRCLE_ZOOM:
			anim_string = "circle_zoom"
		_:
			anim_string = "fade"
	animation_player.play(anim_string)
	await transitioned_halfway
	skip_emit = true
	animation_player.play_backwards(anim_string)


func transition_to_scene(scene_path: String, type: Types = Types.FADE) -> void:
	transition(type)
	await transitioned_halfway
	get_tree().change_scene_to_file(scene_path)


func emit_transitioned_halfway() -> void:
	if skip_emit:
		skip_emit = false
		return
	transitioned_halfway.emit()
