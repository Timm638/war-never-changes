extends Area2D
var GetUnitsAround = preload("res://Scripts/Static/GetUnitsAround.gd")

@export var damage: float = 10.0
@export var crater_size: float = 1.0
@export var crater_scatter: float = 0.75

@onready var damage_area: CollisionShape2D = $"Damage Area"
var wait_for_physic_update : bool = true

func _physics_process(delta: float) -> void:
	apply_damage()
	GlobalSignalSingleton.craterCreated.emit(self, crater_size, crater_scatter)
	queue_free()  
		
func apply_damage():
	var unit_list = GetUnitsAround.getUnitsAround(self)
	for obj in unit_list:
		if obj is Unit:
			obj.take_damage(damage, self)
