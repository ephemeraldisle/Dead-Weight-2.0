extends Node

const SONG_FADE_TIME := 0.5
const INTRO_FADE_TIME := 0.1


@export var generic_player: PackedScene
@export var ui_clicks: PackedScene

var _current_song: AudioStreamPlayer

@onready var intro_music: AudioStreamPlayer = $IntroMusic
@onready var alarm_looper: AudioStreamPlayer = $AlarmLooper
@onready var soft_loop: AudioStreamPlayer = $SoftLoop
@onready var main_song: AudioStreamPlayer = $MainSong
@onready var menu_song: AudioStreamPlayer = $MenuSong


func _ready():
	intro_music.play()
	_current_song = intro_music
	fade_volume(intro_music, g.SILENT_DB, g.NORMAL_DB, INTRO_FADE_TIME)

func _attempt_play(audio_player: PackedScene, position: Vector2, audio: AudioStream, volume: float = g.NORMAL_DB):
	var stream = audio_player.instantiate()
	add_child(stream)
	stream.global_position = position
	if audio != null: 
		stream.stream = audio
	stream.volume_db = volume
	stream.play()

func _crossfade(new_song: AudioStreamPlayer):
	var old_song = _current_song
	_current_song = new_song
	fade_volume(old_song, g.NORMAL_DB, g.SILENT_DB, SONG_FADE_TIME)
	_current_song.play()
	fade_volume(_current_song, g.SILENT_DB, g.NORMAL_DB, SONG_FADE_TIME)
	await get_tree().create_timer(SONG_FADE_TIME).timeout	
	old_song.stop()

func switch_to_main_song():
	_crossfade(main_song)

func switch_to_menu_song():
	_crossfade(menu_song)

func request_audio(audio_player: PackedScene, position: Vector2):
	var stream = audio_player.instantiate()
	add_child(stream)
	if stream is AudioStreamPlayer2D:
		stream.global_position = position
	stream.play()

func play_generic(audio: AudioStream, position: Vector2 = Vector2.ZERO, volume: float = g.NORMAL_DB):
	_attempt_play(generic_player, position, audio, volume)

func play_ui_click():
	request_audio(ui_clicks, Vector2.ZERO)
 
func fade_volume(player: AudioStreamPlayer, from_volume: float, to_volume: float, duration: float):
	var tween: Tween = create_tween()

	player.volume_db = from_volume
	if from_volume > to_volume:
		tween.tween_property(player, g.DB_PROPERTY, to_volume, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(player, g.DB_PROPERTY, to_volume, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
