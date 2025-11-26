extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music(load("res://UI/Musics/retro-arcade-game-music-297305.ogg"))
