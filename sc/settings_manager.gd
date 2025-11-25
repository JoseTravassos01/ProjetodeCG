extends Node

signal resolution_changed(resolution: Vector2i)

var settings_data: SettingsDataResource

const SAVE_PATH := "user://settings_data.tres"


func _ready():
	# Carrega as configs assim que o jogo abre
	load_settings()
	# Aplica o que foi carregado
	_apply_window_mode()
	_apply_resolution()


func load_settings():
	if ResourceLoader.exists(SAVE_PATH):
		settings_data = ResourceLoader.load(SAVE_PATH) as SettingsDataResource

	if settings_data == null:
		settings_data = SettingsDataResource.new()

	print("LOAD settings:",
		" window_mode:", settings_data.window_mode,
		" resolution:", settings_data.resolution)


func save_settings():
	if settings_data == null:
		return
	var err := ResourceSaver.save(settings_data, SAVE_PATH)
	print("SAVE settings: err =", err)


func set_window_mode(window_mode: int, window_mode_index: int):
	settings_data.window_mode = window_mode
	settings_data.window_mode_index = window_mode_index
	_apply_window_mode()
	print("set_window_mode:", window_mode, "index:", window_mode_index)


func set_resolution(resolution: Vector2i, resolution_index: int):
	settings_data.resolution = resolution
	settings_data.resolution_index = resolution_index
	_apply_resolution()
	print("set_resolution:", resolution, "index:", resolution_index)


func _apply_window_mode():
	match settings_data.window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_resolution():
	var res := settings_data.resolution
	var mode := DisplayServer.window_get_mode()

	# WINDOW / MAXIMIZED -> muda o tamanho da janela
	if mode == DisplayServer.WINDOW_MODE_WINDOWED or mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_size(res)

	# FULLSCREEN -> SO manda no tamanho físico, câmera cuida do zoom
	emit_signal("resolution_changed", res)

	print("APPLY resolution:", res, "mode:", mode)


func get_settings() -> SettingsDataResource:
	return settings_data
