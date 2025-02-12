## Handles health
extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@onready var current_health: float = max_health

@export var max_health: float = 1
@export var is_invulnerable: bool = false


func damage(damage_amount: float) -> void:
	if is_invulnerable: return 
	current_health = clamp(current_health - damage_amount, 0, max_health)
	health_changed.emit()
	if damage_amount > 0:
		health_decreased.emit()
	Callable(check_death).call_deferred()
	print(current_health)


func heal(heal_amount: float) -> void:
	damage(-heal_amount)

# godot quirk - can't queue free while calculating physics, need to wait until end of frame using Callable(check_death).call_deferred()
func check_death() -> void:
	if current_health == 0:
		died.emit()


func kill() -> void:
	current_health = 0
	died.emit()


func get_health_percentage() -> float:
	if max_health <= 0: 
		return 0
	return min(current_health / max_health, 1)
