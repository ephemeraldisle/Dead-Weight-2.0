extends Node

@export var generic_player: PackedScene
@export var ui_clicks: PackedScene
@onready var intro_music = $IntroMusic as AudioStreamPlayer
@onready var alarm_looper = $AlarmLooper
@onready var soft_loop = $SoftLoop
@onready var main_song = $MainSong


func _ready():
	pass
#	intro_music.play()
#	fade_volume(intro_music, -80, 0, 0.25)

func _attempt_play(audio_player: PackedScene, position: Vector2, audio: AudioStream, volume: float = 0):
	var stream = audio_player.instantiate()
	add_child(stream)
	stream.global_position = position
	if audio != null: 
		stream.stream = audio
	stream.volume_db = volume
	stream.play()

func switch_to_main_song():
	fade_volume(soft_loop, 0,-80, 0.5)
	main_song.play()
	fade_volume(main_song, -80, 0, 0.5)

func request_audio(audio_player: PackedScene, position: Vector2):
	var stream = audio_player.instantiate()
	add_child(stream)
	if stream is AudioStreamPlayer2D:
		stream.global_position = position
	stream.play()

func play_generic(audio: AudioStream, position: Vector2 = Vector2.ZERO, volume: float = 0):
	_attempt_play(generic_player, position, audio, volume)

func play_ui_click():
	request_audio(ui_clicks, Vector2.ZERO)
 
func fade_volume(player: AudioStreamPlayer, from_volume: float, to_volume: float, duration: float):
	# Start a new tween
	var tween: Tween = create_tween()

	player.volume_db = from_volume
	if from_volume > to_volume:
		# Fade out
		tween.tween_property(player, "volume_db", to_volume, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	else:
		# Fade in
		tween.tween_property(player, "volume_db", to_volume, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
