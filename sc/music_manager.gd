extends Node

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(player)
	player.bus = "Music" # opcional, caso você tenha um bus Music no Audio
	player.autoplay = false
	player.volume_db = 0  # volume normal

func play_music(stream: AudioStream):
	if player.stream != stream:
		player.stream = stream
		player.play()

func stop_music():
	player.stop()
