extends CanvasLayer

@export var next_scene_path: String = ""   # definido pelo SceneManager

@onready var fade_rect: ColorRect = $ColorRect
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var label_loading: Label = $Label

var dot_count := 0


func _ready():
	# FadeRect começa totalmente preto
	fade_rect.modulate.a = 1.0

	# Texto inicial
	label_loading.text = "Loading"

	# Inicia animação dos três pontinhos
	_start_loading_dots()

	# Toca o vídeo
	if video_player.stream:
		video_player.play()

	# Inicia o fade-in e depois o loading
	await _fade_in()
	await _loading_time(10.0)  # 10 segundos
	await _fade_out()

	# Troca de cena
	get_tree().change_scene_to_file(next_scene_path)
	await get_tree().process_frame

	queue_free()


# 🔸 Fade-in real (preto → visível)
func _fade_in():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
	return tween.finished


func _fade_out():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	return tween.finished



# 🔸 Timer dos 10 segundos
func _loading_time(seconds: float):
	await get_tree().create_timer(seconds).timeout


# 🔸 Pontinhos animados
func _start_loading_dots():
	var timer := Timer.new()
	timer.wait_time = 0.4
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_update_dots)


func _update_dots():
	dot_count = (dot_count + 1) % 4
	label_loading.text = "Loading" + ".".repeat(dot_count)
