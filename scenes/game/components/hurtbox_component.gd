## HURTBOX is for TAKING DAMAGE
# Collision mask should be what this thing TAKES DAMAGE FROM
extends Area2D
class_name HurtboxComponent

signal taken_damage(damage: float)

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D) -> void:
	if other_area is not HitboxComponent: return
	if health_component == null: return
	
	var hitbox_component: HitboxComponent = other_area
	hitbox_component.get_parent().attack_hit = true
	health_component.damage(hitbox_component.damage)
	
	taken_damage.emit(hitbox_component.damage)
