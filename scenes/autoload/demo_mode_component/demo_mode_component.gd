extends CanvasLayer
# automatically quits after inactivity

@onready var time_idle_label: Label = %TimeIdleLabel

@export var is_demo_mode_active: bool = false
@export var time_until_message: float = 30
@export var time_until_quit: float = 60

var time_idle: float = 0


func _ready() -> void:
	visible = false


func _process(delta: float) -> void:
	if !is_demo_mode_active: return
	time_idle += delta
	if time_idle > time_until_quit:
		exit()
	elif time_idle > time_until_message:
		visible = true
		if Input.is_action_just_pressed("ui_cancel"):
			exit()
	if Input.is_anything_pressed():
		visible = false
		time_idle = 0
	
	time_idle_label.text = """Exiting game after %s more seconds of inactivity!

Press [ESC] to quit now, or any other key to resume.""" % [ abs(ceil(time_until_quit - time_idle)) ]


func exit() -> void:
	get_tree().quit()
