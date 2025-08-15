class_name AudioManager
extends Node

enum Bus{Sfx1, Sfx2}

static func play_sfx(stream:AudioStream, bus:Bus) -> void:
	instance.play_sfx_(stream, bus)
	pass

static var instance:AudioManager
var sfx_index_1:int
var audio_players_1:Array[AudioStreamPlayer2D]
var sfx_index_2:int
var audio_players_2:Array[AudioStreamPlayer2D]

func _init():
	instance=self
	sfx_index_1 = 0
	sfx_index_2 = 0

func _ready() -> void:
	for audio_player in $Sfx_1.get_children():
		audio_players_1.push_back(audio_player as AudioStreamPlayer2D)
	for audio_player in $Sfx_2.get_children():
		audio_players_2.push_back(audio_player as AudioStreamPlayer2D)


func play_sfx_(stream:AudioStream, bus:Bus) -> void:
	var audio_player
	if bus==Bus.Sfx1:
		audio_player = audio_players_1[sfx_index_1]
		sfx_index_1 += 1
		sfx_index_1 %= audio_players_1.size()
	elif bus == Bus.Sfx2:
		audio_player = audio_players_2[sfx_index_2]
		sfx_index_2 += 1
		sfx_index_2 %= audio_players_2.size()
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()
   
	pass
