class_name  Batallion
extends Resource

var units:Array[Unit]
var rallying:bool
var leader:Unit
var target:Node2D
var target_batallion:Batallion

func _init() -> void:
	rallying = true

func compute_centroid() -> Vector2:
	var centroid = Vector2.ZERO
	var c = 0.0
	for unit:Unit in units:
		if !unit:
			continue
		centroid += unit.position
		c += 1
	return centroid / c
