extends Node

var scenes: Dictionary = {
	"Level1": "res://levels/test_level/level_1.tscn",
	"Level2": "res://levels/test_level/level_2.tscn",
	"Level3": "res://levels/test_level/level_3.tscn",
	"FinalText": "res://levels/test_level/final_text.tscn"  # <-- CLICA NO final_text.tscn, COPIA O PATH E CONFERE
}

var loading_scene := preload("res://UI/scene_loading/canvas_layer.tscn")


func transition_to_scene(level: String) -> void:
	var scene_path: String = scenes.get(level, "")
	if scene_path == "":
		push_warning("SceneManager: level '%s' não encontrado no dictionary 'scenes'." % level)
		return

	# limpa chaves
	InvetoryManager.reset_keys()

	# 👇 AQUI: FinalText VAI DIRETO, SEM LOAD
	if level == "FinalText":
		get_tree().change_scene_to_file(scene_path)
		return

	# pros outros levels usa tela de loading
	_show_loading(scene_path)


func _show_loading(scene_path: String) -> void:
	var loading = loading_scene.instantiate()
	loading.next_scene_path = scene_path
	get_tree().root.add_child(loading)
