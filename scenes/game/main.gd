extends Node2D

@onready var arena_layout_container: Node2D = %ArenaLayoutContainer

var arena_layout_intro_scene: String = "res://scenes/arena/arena_layout_1.tscn"

var arena_layout_scenes: Array[String] = [
	"res://scenes/arena/arena_layout_1.tscn",
	"res://scenes/arena/arena_layout_2.tscn",
	"res://scenes/arena/arena_layout_3.tscn",
	"res://scenes/arena/arena_layout_4.tscn",
	"res://scenes/arena/arena_layout_5.tscn",
	"res://scenes/arena/arena_layout_6.tscn",
	"res://scenes/arena/arena_layout_7.tscn"
]


func _ready() -> void:
	spawn_layout()
	AudioController.play_sfx(AudioController.SFX_START)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func spawn_layout() -> void:
	var layout_scene: PackedScene
	if ScoreManager.scores == [ 0, 0 ]:
		layout_scene = load(arena_layout_intro_scene)
	else:
		layout_scene = load(arena_layout_scenes.pick_random())
	var layout_instance: Node2D = layout_scene.instantiate()
	arena_layout_container.add_child(layout_instance)
