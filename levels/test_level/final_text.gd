extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music(load("res://UI/Musics/medieval-fanfare-6826(1).mp3"))
