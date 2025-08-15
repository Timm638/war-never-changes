class_name TestUnitSpawner
extends Node


@export var unit_prefab:PackedScene
@export var num_units:int = 1000
@export var world:Node2D
@export var batallion_size:int = 20


func _ready() -> void:
	var battallion_counter = 0
	var curr_batallion: Batallion = Batallion.new()
	for i in range (0, num_units):
		var inst = unit_prefab.instantiate() as Node2D
		var pos = Vector2(960+(1-2*sin(randf()*PI))*(randi()%960), 540+(1-2*cos(randf()*PI))*(randi()%540))
		world.add_child.call_deferred(inst)
		inst.position = pos
		curr_batallion.units.push_back(inst)
		for child in inst.get_children():
			if child is BatallionMove:
				var bm := child as BatallionMove
				bm.batallion = curr_batallion
				
		if battallion_counter >= batallion_size:
			battallion_counter = 0
			curr_batallion = Batallion.new()
