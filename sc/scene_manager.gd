extends Node

var scenes: Dictionary = {
	"Level1": "res://levels/test_level/level_1.tscn",
	"Level2": "res://levels/test_level/level_2.tscn",
	"Level3": "res://levels/test_level/level_3.tscn"
}

var loading_scene := preload("res://UI/scene_loading/canvas_layer.tscn")


func transition_to_scene(level: String) -> void:
	var scene_path: String = scenes.get(level, "")
	if scene_path == "":
		push_warning("SceneManager: level '%s' não encontrado no dictionary 'scenes'." % level)
		return

	# 🔹 AQUI: limpa as chaves antes de ir pra próxima fase
	InvetoryManager.reset_keys()

	_show_loading(scene_path)


func _show_loading(scene_path: String) -> void:
	# Instancia a tela de loading
	var loading = loading_scene.instantiate()
	loading.next_scene_path = scene_path

	# Joga no root pra ficar sempre por cima de tudo
	get_tree().root.add_child(loading)
