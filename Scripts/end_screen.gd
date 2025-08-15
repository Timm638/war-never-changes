extends CanvasLayer

@export var ranks = ["D", "C", "B", "A", "S"]
@export var rank_color = [null, null, null, null, Color.YELLOW]
@export var rank_subtext = ["Peacekeeper", "Insider", "7th Layer of Hell", "Reaper's Right Hand", "The Reaper"]

@export_file("*.tscn") var main_game : String

# in seconds
@export var duration_caps = [0, 30, 60, 180]
@export var soul_caps = [0, 100, 500, 1000]
@export var actions_used_caps = [0, 1, 5, 10]

@export var cur_time: float = 0.0
var time_start: int = 0
@export var cur_skills_used: int = 0
@export var cur_souls_collected: int = 0

func _ready() -> void:
	self.visible = false
	GlobalSignalSingleton.connect("startGame", start_timer)
	GlobalSignalSingleton.connect("endGame", end_game)
	GlobalSignalSingleton.connect("unitDied", count_soul)
	GlobalSignalSingleton.connect("skillUsed", count_skill)

func start_timer():
	time_start = Time.get_ticks_msec() / 1000

func count_soul(_unit):
	cur_souls_collected += 1

func count_skill():
	cur_skills_used += 1

func end_game() -> void:
	var time_end = Time.get_ticks_msec() / 1000
	cur_time = int(time_end - time_start)
	#DEBUG
	#cur_souls_collected = 10000
	#cur_skills_used = 10000
	#cur_time = 3600
	Engine.time_scale = 0.0
	update_text_boxes()
	self.visible = true
	for c in get_tree().get_nodes_in_group("Pause on Start"):
		if c is Actor:
			c.paused = true
		elif c is CanvasLayer:
			c.visible = false

func restart_game() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func update_text_boxes():
	$%SkillsUsed.text = str(cur_skills_used)
	$%SoulCount.text = str(cur_souls_collected)
	
	var minutes: int = floor(cur_time / 60)
	var seconds: int = floori(cur_time) % 60
	var mid_text = ":0" if seconds < 10 else ":"	
	$%WarDuration.text = str(minutes) + mid_text + str(seconds)
	
	var ranks_arr = [
		[cur_time, duration_caps, $%DurationRank], 
		[cur_souls_collected, soul_caps, $%SoulRank],
		[cur_skills_used, actions_used_caps, $%SkillRank]
	]
	var rank_points = 0
	for x in ranks_arr:
		var cur_rank = 0
		while (cur_rank < len(x[1]) and x[0] > x[1][cur_rank]):
			cur_rank += 1
		x[2].text = ranks[cur_rank]
		if rank_color[cur_rank] != null:
			x[2].get_parent().modulate = rank_color[cur_rank]
		rank_points += cur_rank
	var overall_rank: int = floori(rank_points / 3)
	$%OverallRank.text = ranks[overall_rank]
	if rank_color[overall_rank] != null:
		$%OverallRank.get_parent().modulate = rank_color[overall_rank]
	$%SubText.text = rank_subtext[overall_rank]
	
