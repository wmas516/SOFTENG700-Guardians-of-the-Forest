extends Node

const LEVEL_TRACK: AudioStream = preload("res://resources/audio/Level_1_mixdown.mp3")

var music_player: AudioStreamPlayer


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = LEVEL_TRACK
	music_player.bus = "Music"
	music_player.set("parameters/looping", true)
	add_child(music_player)


func play_level_music() -> void:
	if not music_player.playing:
		music_player.play()


func stop_level_music() -> void:
	music_player.stop()
