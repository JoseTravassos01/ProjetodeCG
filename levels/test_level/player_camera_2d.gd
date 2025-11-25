extends Camera2D

# Resolução base que você considera "normal"
const BASE_RESOLUTION := Vector2(854, 480)


func _ready():
	# Aplica zoom baseado na resolução carregada
	var data := SettingsManager.get_settings()
	if data != null:
		set_zoom_for_resolution(data.resolution)

	# Atualiza zoom em tempo real quando a resolução mudar
	SettingsManager.resolution_changed.connect(set_zoom_for_resolution)


func set_zoom_for_resolution(resolution: Vector2i):
	var res_vec := Vector2(resolution.x, resolution.y)

	# Maior resolução -> menos zoom (enxerga mais área)
	var scale := BASE_RESOLUTION / res_vec

	if scale.x <= 0.0 or scale.y <= 0.0:
		scale = Vector2.ONE

	zoom = scale
	print("Camera zoom:", zoom, " resolution:", resolution)
