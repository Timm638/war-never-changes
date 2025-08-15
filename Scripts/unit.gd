class_name Unit
extends Node2D

enum State {MOVE = 0, ATTACK = 1, GRABBED = 2, RALLYING = 3, DYING = 4}

@export var max_hp:int = 1

@export var sprite:Sprite2D
@export var death_sprite:Sprite2D
@export var weapon_sprite:Sprite2D

@export var base_animations:AnimationPlayer
@export var hurt_animation:AnimationPlayer

@export var take_damage_sfx:AudioStream

var state:State:
	get:
		return state
	set(value):
		if value==State.MOVE:
			base_animations.stop()
			if base_animations.current_animation != "death":
				base_animations.play("walk")
		else:
			#base_animations.stop()
			pass
		state = value
var hp:int
var controlled_by:Actor
var batallion:Batallion
var vel:Vector2

func _ready() -> void:
	hp = max_hp

func setup(boss:Actor, settings:ActorSettings) -> void:
	self.controlled_by = boss
	$Area2D.collision_layer = controlled_by.unit_layer
	set_correct_sprite(boss.is_player_1, boss.age_index)

func _exit_tree() -> void:

	if batallion.units.has(self):
		batallion.units.erase(self)
	if batallion.leader == self:
		if batallion.units.size() > 0:
			batallion.leader = batallion.units[randi()%batallion.units.size()]
			
	# Notify for soul
	GlobalSignalSingleton.unitDied.emit(self)

#epoch
#0==Steinzeit
#1==Mittelater
#2==Neuzeit
func set_correct_sprite(is_enemy:bool,epoch:int)->void:
	var tile_y: int = sprite.texture.get_size().y / 6
	var tile_x: int = tile_y
	sprite.region_rect.position.y = epoch * tile_y * 2 + (is_enemy as int) * tile_y
	weapon_sprite.region_rect.position.y=epoch * 32

func take_damage(amount:int, _source:Node2D) -> void:
	if hp <= 0:
		return
	hp -= amount
	AudioManager.play_sfx(take_damage_sfx, AudioManager.Bus.Sfx2)
	if hp <= 0:
		state = State.DYING
		hurt_animation.play("RESET")
		base_animations.play("death")
		die_delayed()
	else:
		hurt_animation.play("hurt")

func die_delayed() -> void:
	await get_tree().create_timer(0.5).timeout
	queue_free()
