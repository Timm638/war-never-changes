class_name Actor
extends Node

enum Epoch{Stoneage = 0, Medieval = 1, Modern = 2}

@export var castle:Castle
@export var settings:ActorSettings:
	set(new_set):
		settings = new_set
		age_changed.emit(settings)
@export var progression:ActorProgression
@export var enemy:Actor
@export_flags_2d_physics var unit_layer:int
@export var world:Node2D
@export var is_player_1:bool

@export var paused: bool = false
@export var color:Color
@export var simultaneous_attention:int = 2


var age_index:int
var t_batallion:float
var t_ai:float
var t_age:float
var t_age_interval:float
var batallions:Array[Batallion]
var all_depots:Array[ResourceDepot]
var batallion_attention:int

signal age_changed(settings: ActorSettings)

func _input(event: InputEvent) -> void:
	if event.is_action("advance_age"):
		advance_age()


func _ready() -> void:
	all_depots = []
	age_index = 0
	t_batallion = 0
	t_ai = 0
	t_age = 0
	t_age_interval = 0
	batallion_attention = 0
	castle.controlled_by = self
	for child in castle.get_children():
		if child is Area2D:
			(child as Area2D).collision_layer = unit_layer
	settings = progression.settings_by_age[age_index]
	batallions = []
	
	for child in world.get_children():
		if child is ResourceDepot:
			all_depots.push_back(child as ResourceDepot)

func _physics_process(delta: float) -> void:
	if castle && enemy.castle && not paused:
		update(delta)
	elif !castle && not paused:
		paused = true
		GlobalSignalSingleton.endGame.emit()
		

func update(delta:float) -> void:
	update_spawn(delta)
	update_ai(delta)
	update_age_progress(delta)

func update_age_progress(delta:float) -> void:
	t_age += delta
	if t_age > progression.min_age_duration:
		t_age_interval += delta
		if t_age_interval >= progression.age_transiton_interval:
			t_age_interval = 0
			if randf() <= progression.transition_probability:
				advance_age()

				
func advance_age() -> void:
	age_index += 1
	age_index = min(progression.settings_by_age.size() - 1, age_index)
	t_age = 0
	t_age_interval = 0
	settings = progression.settings_by_age[age_index]

func update_spawn(delta:float) -> void:
	t_batallion += delta
	if t_batallion >= settings.batallion_spawn_interval:
		t_batallion = 0
		create_batallion()

func update_ai(delta:float) -> void:
	t_ai += delta
	if t_ai > settings.ai_update_interval:
		t_ai = 0
		update_batallions(delta)

func update_batallions(delta:float) -> void:
	
	
	var interested_in:Array[Node2D] = []
	interested_in.push_back(enemy.castle)
	for depot:ResourceDepot in all_depots:
		if depot.controlled_by != self:
			interested_in.push_back(depot)
			
	for i in range(batallions.size() - 1, - 1, -1):
		var batallion:=batallions[i]
		if batallion.units.size() == 0:
			batallions.remove_at(i)
			continue
	if batallions.size() <= 0:
		return
	if interested_in.size() <= 0:
		return
	for i in range(0,simultaneous_attention):
		var idx = (batallion_attention+i)%batallions.size()
		update_batallion_ai(batallions[idx], interested_in[randi()%interested_in.size()])
		
	batallion_attention += simultaneous_attention
	batallion_attention = batallion_attention%batallions.size()

func update_batallion_ai(batallion:Batallion, interested_in:Node2D) -> void:
	batallion.target = interested_in


func set_ranged_batallion_target(batallion:Batallion, _leader_attack :RangedAttackHitscan) -> void:
	if enemy.batallions.size() > 0:
		var enemy_batallion := enemy.batallions[randi() % enemy.batallions.size()]
		batallion.target_batallion = enemy_batallion

func create_batallion() -> void:
	var unit_type = settings.unit_type_bag[randi() % settings.unit_type_bag.size()]
	var batallion:Batallion = Batallion.new()
	batallion.rallying = true
	var batallion_spawn:Vector2 = castle.position + (enemy.castle.position - castle.position).normalized()
	var tau := randf()*2*PI
	batallion_spawn += settings.spawn_radius*Vector2(cos(tau), -sin(tau))
	
	var mul_from_resources = 1.0
	for depot:ResourceDepot in all_depots:
		if depot.controlled_by == self:
			mul_from_resources += depot.unit_spawn_increase_factor
	var batallion_size := randi()%roundi(settings.batallion_size*mul_from_resources)
	for i in range(0, batallion_size):
		spawn_unit_to_batallion(batallion, unit_type, batallion_spawn)				
		
		await get_tree().create_timer(settings.unit_spawn_interval).timeout
	
	await get_tree().create_timer(0.1).timeout
	if batallion.units.size() >0:
		batallion.leader = batallion.units[randi()%batallion.units.size()]
	for unit in batallion.units:
		if unit:
			unit.state = Unit.State.MOVE
	if !batallions.has(batallion):
		batallion.rallying = false
		batallions.push_back(batallion)


func spawn_unit_to_batallion(batallion:Batallion, unit_type:PackedScene, batallion_spawn:Vector2) -> void:
	var inst = unit_type.instantiate() as Unit	
	inst.setup(self, settings)
	
	batallion.units.push_back(inst)
	inst.batallion = batallion

	world.add_child(inst)
	var tau = randf() * 2 * PI
	inst.position = batallion_spawn + Vector2(cos(tau), -sin(tau))*settings.spawnpoint_diameter*randf()
	inst.state = Unit.State.RALLYING
	for child in inst.get_children():
		if child is BatallionMove:
			var bmove = child as BatallionMove
			bmove.batallion = batallion
			if enemy.castle:
				bmove.trg = enemy.castle.position
