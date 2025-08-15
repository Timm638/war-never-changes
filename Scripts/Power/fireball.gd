extends Area2D
var GetUnitsAround = preload("res://Scripts/Static/GetUnitsAround.gd")

@export var start_height: float = 1000.0  # pixels above origin
@export var start_height_variance: float = 0.25
@export var fall_speed: float = 330.0    # pixels per second
@export var damage: float = 10.0
@export var crater_size: float = 5.0
@export var crater_scatter: float = 0.25

var blocked:bool=false

@onready var damage_area: CollisionShape2D = $"Damage Area"

@export var damage_area_sprite: Node2D
@export var sprite: Node2D
@export var death_particles: GPUParticles2D

func _ready():
	var variation = 1.00 + (2 * start_height_variance * randf() - start_height_variance)
	sprite.position.y = -start_height * variation

func _process(delta):
	if !blocked:
		# Move sprite down
		sprite.position.y += fall_speed * delta

		# Check if sprite has reached or passed origin
		if sprite.position.y >= 0:
			apply_damage()
			GlobalSignalSingleton.craterCreated.emit(self, crater_size, crater_scatter)
			sprite.visible=false
			death_particles.emitting=true
			damage_area_sprite.visible=false
			blocked=true
			await death_particles.finished
			queue_free()  
		
func apply_damage():
	var unit_list = GetUnitsAround.getUnitsAround(self)
	for obj in unit_list:
		if obj is Unit:
			obj.take_damage(damage, self)
