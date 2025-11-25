extends Node

var settings_data: SettingsDataResource

const SAVE_DIR := "user://game_data/"
const SAVE_FILE := "settings_data.tres"


func load_settings():
	# Garante que a pasta user://game_data existe
	var dir := DirAccess.open("user://")
	if dir != null:
		if not dir.dir_exists("game_data"):
			dir.make_dir("game_data")

	# Carrega o arquivo se existir
	if ResourceLoader.exists(SAVE_DIR + SAVE_FILE):
		settings_data = ResourceLoader.load(SAVE_DIR + SAVE_FILE) as SettingsDataResource

	# Se ainda for null, cria um novo resource com os defaults
	if settings_data == null:
		settings_data = SettingsDataResource.new()

	# Aplica as config salvas (ou os defaults, se for novo)
	if settings_data != null:
		set_window_mode(settings_data.window_mode, settings_data.window_mode_index)
		set_resolution(settings_data.resolution, settings_data.resolution_index)


func set_window_mode(window_mode: int, window_mode_index: int):
	# Aceita tanto FULLSCREEN quanto EXCLUSIVE_FULLSCREEN
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Salva nos dados
	settings_data.window_mode = window_mode
	settings_data.window_mode_index = window_mode_index


func set_resolution(resolution: Vector2i, resolution_index: int):
	# 🔹 AQUI SIMPLIFICA TUDO:
	# só muda o tamanho da janela, sem mexer em scale/zoom
	DisplayServer.window_set_size(resolution)

	print("Resolução aplicada: ", resolution)

	# Salva nos dados
	settings_data.resolution = resolution
	settings_data.resolution_index = resolution_index


func get_settings() -> SettingsDataResource:
	return settings_data


func save_settings():
	if settings_data == null:
		return
	ResourceSaver.save(settings_data, SAVE_DIR + SAVE_FILE)
