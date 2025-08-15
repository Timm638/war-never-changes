extends Projectile
class_name ExplosiveProjectile

@export var damage: float = 10.0
@export var damage_range: float = 10.0
@export var crater_size: float = 2.0
@export var crater_percentage: float = 0.5

const EXPLOSION = preload("res://Scenes/Prefabs/Powers/explosion.tscn")

func target_reached() -> void:
	if target:
		var explosion = EXPLOSION.instantiate()
		explosion.damage = damage
		var dmg_area = explosion.get_node("Damage Area")
		dmg_area.shape.radius = damage_range
		explosion.crater_size = crater_size
		explosion.crater_scatter = crater_percentage
		get_parent().add_child(explosion)
		explosion.global_position = target.global_position
	queue_free()
	
