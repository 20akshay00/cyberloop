extends AudioStreamPlayer2D

var loop_created_sfx := load("res://assets/sfx/Loop Created Longer 2.mp3")
var fall_sfx := load("res://assets/sfx/Spiral long.mp3")
var loop_invalid_sfx := load("res://assets/sfx/Cannot Form Loop.mp3")
var power_full_sfx := load("res://assets/sfx/Power full.mp3")
var draw_start_sfx := load("res://assets/sfx/Trail Draw Start.mp3")
var power_empty_sfx := load("res://assets/sfx/Power Empty.mp3")
var player_hit_sfx := load("res://assets/sfx/Player Hit 2.mp3")
var enemy_shoot_sfx := load("res://assets/sfx/Enemy shooting.mp3")
var explosion_sfx := load("res://assets/sfx/Explosion.mp3")

func _play_music(music: AudioStream, volume = -7):
	if stream == music:
		return

	stream = music
	volume_db = volume
	play()

func play_music_level():
	pass

func play_effect(aud_stream: AudioStream, volume = 0.0, loops = false):
	var fx_player = AudioStreamPlayer2D.new()
	fx_player.stream = aud_stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	add_child(fx_player)
	fx_player.play()
	if not loops: 
		fx_player.finished.connect(fx_player.queue_free)

	return fx_player
