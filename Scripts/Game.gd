extends Node2D

var konoDioDa: String = "Goodbye, Jojo!"
var saveKey = "GAME"
var levels: Dictionary = {
	"1F_main_room": preload("res://Scenes/levels/1F_main_room.tscn").instance(),
	"1F_west_hall": preload("res://Scenes/levels/1F_west_hall.tscn").instance()
}


func switchScene(scene_name: String) -> void:
	if levels[scene_name] == null:
		return

	var c = self.get_children()
	var prev_scene = c[0].get_name()
	print(prev_scene)
	levels[prev_scene] = c[0]
	remove_child(c[0])
	add_child(levels[scene_name])


func saveGame(game_save: Resource) -> void:
	game_save.data[saveKey] = {
		'levels': {'1F_main_room': levels["1F_main_room"], '1F_west_hall': levels["1F_west_hall"]}
	}


func loadGame(game_save: Resource) -> void:
	var data = game_save.data[saveKey]
	levels["1F_main_room"] = data['levels']['1F_main_room']
	levels["1F_west_hall"] = data['levels']['1F_west_hall']


func _on_Door_player_entered(scene_name) -> void:
	switchScene(scene_name)
	print(scene_name)
