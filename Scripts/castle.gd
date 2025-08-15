class_name Castle
extends Node2D


@export var max_hp:int = 2000
var hp:int
var controlled_by:Actor:
	set(actor):
		if (controlled_by != null):
			hp_bar_fill.color = actor.color
			controlled_by.age_changed.disconnect(update_age)
		controlled_by = actor
		if (controlled_by != null):
			hp_bar_fill.color = actor.color
			controlled_by.age_changed.connect(update_age)

@export var hp_bar_fill:ColorRect

func _ready() -> void:
	hp = max_hp
	
	
func _process(_delta: float) -> void:
	pass

func take_damage(amount:int, _source:Node2D) -> void:
	if hp <= 0:
		return
	hp -= amount	
	$HpBar/Fill.scale.x= float(hp)/float(max_hp)
	if hp <= 0:
		queue_free()

func update_age(settings: ActorSettings):
	$Sprite2D.texture = settings.base_txt
