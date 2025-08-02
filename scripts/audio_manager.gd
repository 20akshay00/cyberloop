extends AudioStreamPlayer

var loop_created_sfx := load("res://assets/sfx/Loop Created Longer 2.mp3")
var fall_sfx := load("res://assets/sfx/Spiral long.mp3")
var loop_invalid_sfx := load("res://assets/sfx/Cannot Form Loop.mp3")
var enemy_shoot_sfx := load("res://assets/sfx/Enemy shooting.mp3")

func _play_music(music: AudioStream, volume = -7):
	if stream == music:
		return

	stream = music
	volume_db = volume
	play()

func play_music_level():
	pass

func play_effect(aud_stream: AudioStream, volume = 0.0, loops = false):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = aud_stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	fx_player.bus = "Misc"
	add_child(fx_player)
	fx_player.play()
	if not loops: 
		fx_player.finished.connect(fx_player.queue_free)

	return fx_player
