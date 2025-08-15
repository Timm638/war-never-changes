class_name ResourceDepot
extends Node2D


@export var unit_spawn_increase_factor:float = 2.0
@export var controlled_by_indicator:ColorRect
@export var update_control_interval:float = 0.5
@onready var col:Area2D = $Area2D

var t:float
var controlled_by:Actor:
	get:
		return controlled_by
	set(value):
		if value == null:
			controlled_by_indicator.color = Color.WHITE
		else:
			controlled_by_indicator.color = value.color
		controlled_by=value
func _ready() -> void:
	t = randf() * update_control_interval

func _physics_process(delta: float) -> void:
	t += delta
	
	if t > update_control_interval:
		t = 0
		update_control()
		
func update_control() -> void:
	var areas := col.get_overlapping_areas()
	var actor1:Actor
	var actor2:Actor
	var num_a = 0
	var num_b = 0
	
	for area:Area2D in areas:
		if area.get_parent() is Unit:
			var unit := area.get_parent() as Unit
			if !actor1:
				actor1=unit.controlled_by
			if unit.controlled_by == actor1:
				num_a +=1
			else:
				if !actor2:
					actor2 = unit.controlled_by
				num_b +=1
				
	if num_a > 2 * num_b:
		controlled_by = actor1
	elif num_b > 2 * num_a:
		controlled_by = actor2
	elif num_a > 0 && num_b > 0:
		controlled_by = null
		
	
