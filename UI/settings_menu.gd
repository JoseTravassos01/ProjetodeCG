extends CanvasLayer

@onready var window_mode_option_button: OptionButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/WindowModeOptionButton
@onready var resolution_mode_option_button: OptionButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ResolutionOptionButton

var window_modes: Dictionary = {
	"Fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Window": DisplayServer.WINDOW_MODE_WINDOWED,
	"Window Maximized": DisplayServer.WINDOW_MODE_MAXIMIZED
}

var resolutions: Dictionary = {
	"320x180": Vector2i(320, 180),
	"480x270": Vector2i(480, 270),
	"640x360": Vector2i(640, 360),
	"854x480": Vector2i(854, 480),
	"1280x720": Vector2i(1280, 720)
}


func _ready():
	# Preenche os OptionButtons
	for window_mode in window_modes.keys():
		window_mode_option_button.add_item(window_mode)

	for resolution in resolutions.keys():
		resolution_mode_option_button.add_item(resolution)

	# Pega o que está salvo no SettingsManager
	var data := SettingsManager.get_settings()

	window_mode_option_button.selected = clamp(data.window_mode_index, 0, window_mode_option_button.item_count - 1)
	resolution_mode_option_button.selected = clamp(data.resolution_index, 0, resolution_mode_option_button.item_count - 1)


func _on_window_mode_option_button_item_selected(index: int):
	var window_mode_name := window_mode_option_button.get_item_text(index)
	var window_mode := window_modes[window_mode_name] as int

	SettingsManager.set_window_mode(window_mode, index)
	print("Selecionou modo:", window_mode_name, "->", window_mode)



func _on_main_menu_button_pressed():
	SettingsManager.save_settings()
	queue_free()


func _on_resolution_option_button_item_selected(index: int) -> void:
	var resolution_name := resolution_mode_option_button.get_item_text(index)
	var resolution := resolutions[resolution_name] as Vector2i

	SettingsManager.set_resolution(resolution, index)
	print("Selecionou resolução:", resolution_name, "->", resolution)
