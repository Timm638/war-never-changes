# Battle.gd (Godot 4.x)
class_name BattleManager
extends Node2D

const TEAM_A := 0
const TEAM_B := 1

# --- Tuning knobs ---
const UNITS_PER_TEAM := 2500
const MAX_NEIGHBORS := 10
const RADIUS := 8.0                 # half of your QuadMesh size
const CELL_SIZE := RADIUS * 2.5     # good starting point
const SPEED := 90.0
const SEP_FORCE := 240.0
const ARRIVE_RADIUS := 48.0
const ATTACK_RANGE := 16.0
const ATTACK_COOLDOWN := 0.5
const DAMAGE := 10.0

# AI tick downsample (movement @60, decisions @10)
const AI_HZ := 10
var _ai_accum := 0.0

# --- Data: Structure-of-Arrays for speed ---
var pos := PackedVector2Array()
var vel := PackedVector2Array()
var team := PackedInt32Array()
var hp := PackedFloat32Array()
var cd := PackedFloat32Array()   # attack cooldown

# per-team indices (for quick sampling)
var idx_a := PackedInt32Array()
var idx_b := PackedInt32Array()

# Spatial hash
var grid: SpatialHash

# Rendering
@onready var mm_a: MultiMeshInstance2D = $TeamA
@onready var mm_b: MultiMeshInstance2D = $TeamB

func _ready() -> void:
	randomize()
	grid = SpatialHash.new()
	grid.cell_size = CELL_SIZE

	_init_units()
	_init_multimeshes()

func _init_units() -> void:
	var total := UNITS_PER_TEAM * 2
	pos.resize(total)
	vel.resize(total)
	team.resize(total)
	hp.resize(total)
	cd.resize(total)

	idx_a = PackedInt32Array()
	idx_b = PackedInt32Array()

	# Spawn two blobs opposite sides
	for i in UNITS_PER_TEAM:
		var p := Vector2(randf() * 600.0 + 100.0, randf() * 400.0 + 100.0)
		pos[i] = p
		vel[i] = Vector2.ZERO
		team[i] = TEAM_A
		hp[i] = 1.0
		cd[i] = 0.0
		idx_a.push_back(i)

	for j in UNITS_PER_TEAM:
		var i2 := UNITS_PER_TEAM + j
		var p2 := Vector2(randf() * 600.0 + 900.0, randf() * 400.0 + 100.0)
		pos[i2] = p2
		vel[i2] = Vector2.ZERO
		team[i2] = TEAM_B
		hp[i2] = 1.0
		cd[i2] = 0.0
		idx_b.push_back(i2)

func _init_multimeshes() -> void:
	# Each MultiMesh draws only its team's units (cheap!)
	mm_a.multimesh.instance_count = idx_a.size()
	mm_b.multimesh.instance_count = idx_b.size()

	# Optional: random initial rotations
	#for k in idx_a.size():
	#	mm_a.multimesh.set_instance_transform_2d(k, Transform2D(0.0, pos[idx_a[k]]))
	#for k in idx_b.size():
	#	mm_b.multimesh.set_instance_transform_2d(k, Transform2D(0.0, pos[idx_b[k]]))

var centroid_a := Vector2.ZERO
var centroid_b := Vector2.ZERO

func _process(delta: float) -> void:
	_ai_accum += delta

	# rebuild grid
	grid.clear()
	for i in pos.size():
		if hp[i] > 0.0:
			grid.insert(i, pos[i])

	# PRECOMPUTE CENTROIDS (O(N))
	centroid_a = _centroid_fast(idx_a)
	centroid_b = _centroid_fast(idx_b)

	_update_movement(delta)

	if _ai_accum >= 1.0 / AI_HZ:
		var step := _ai_accum
		_ai_accum = 0.0
		_update_combat_and_targets(step)

	_upload_transforms()

func _centroid_fast(indices: PackedInt32Array) -> Vector2:
	var sum := Vector2.ZERO
	var count := 0
	for i in indices:
		if hp[i] > 0.0:
			sum += pos[i]
			count += 1
	if (count > 0): 
		return sum / float(count)
	else: 
		return Vector2.ZERO


func _update_movement(delta: float) -> void:
	for i in pos.size():
		if hp[i] <= 0.0:
			continue

		var p := pos[i]
		var v := vel[i]

		# --- Separation (local) ---
		var sep := Vector2.ZERO
		var count := 0
		var neigh := grid.neighbors(p)
		for n in neigh:
			if n == i or hp[n] <= 0.0:
				continue
			var d := pos[n] - p
			var dist2 := d.length_squared()
			if dist2 <= 0.0001: continue
			if dist2 < (RADIUS * RADIUS * 4.0):
				sep -= d / max(8.0, dist2) # push away
				count += 1
			if count >= MAX_NEIGHBORS: break
		if count > 0:
			sep = sep.normalized() * SEP_FORCE

		# --- Simple arrive towards nearest enemy centroid (cheap heuristic) ---
		var tgt := _team_centroid(1 - team[i])
		var to_tgt := tgt - p
		var dist := to_tgt.length()
		var desired := Vector2.ZERO
		if dist > 1.0:
			var speed := SPEED
			if dist < ARRIVE_RADIUS:
				speed *= (dist / ARRIVE_RADIUS)
			desired = to_tgt.normalized() * speed

		# steering
		var steer := (desired - v) + sep
		v += steer * delta
		var vlen := v.length()
		if vlen > SPEED:
			v = v * (SPEED / vlen)

		p += v * delta

		# keep on map (soft clamp)
		p.x = clamp(p.x, 64.0, 1536.0)
		p.y = clamp(p.y, 64.0, 896.0)

		vel[i] = v
		pos[i] = p

func _team_centroid(t: int) -> Vector2:
	var indices
	if t==TEAM_A:
		return centroid_a
	else:
		return centroid_b

func _update_combat_and_targets(delta: float) -> void:
	# Cooldowns and quick “closest enemy in cell ring” poke
	for i in pos.size():
		if hp[i] <= 0.0:
			continue
		cd[i] = max(0.0, cd[i] - delta)

		var p := pos[i]
		var closest := -1
		var best_d2 := ATTACK_RANGE * ATTACK_RANGE

		var neigh := grid.neighbors(p)
		for n in neigh:
			if team[n] == team[i] or hp[n] <= 0.0:
				continue
			var d2 := (pos[n] - p).length_squared()
			if d2 < best_d2:
				best_d2 = d2
				closest = n

		if closest != -1 and cd[i] <= 0.0:
			# deal damage
			hp[closest] -= DAMAGE
			cd[i] = ATTACK_COOLDOWN

func _upload_transforms() -> void:
	# Team A
	var k := 0
	for i in idx_a:
		if hp[i] > 0.0:
			mm_a.multimesh.set_instance_transform_2d(k, Transform2D(0.0, pos[i]))
		else:
			# move dead offscreen (cheap "despawn")
			mm_a.multimesh.set_instance_transform_2d(k, Transform2D(0.0, Vector2(-9999, -9999)))
		k += 1

	# Team B
	k = 0
	for i in idx_b:
		if hp[i] > 0.0:
			mm_b.multimesh.set_instance_transform_2d(k, Transform2D(0.0, pos[i]))
		else:
			mm_b.multimesh.set_instance_transform_2d(k, Transform2D(0.0, Vector2(-9999, -9999)))
		k += 1
