extends Projectile
class_name HitscanProjectile

@export var damage: float = 10.0

func target_reached() -> void:
	if target:
		target.take_damage(damage, source)
	queue_free()
	
