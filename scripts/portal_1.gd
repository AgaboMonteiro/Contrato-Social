extends Area2D

# Caminho da próxima fase
@export var next_scene_path : String = "res://Scenes/rio_de_janeiro_fase_2.tscn"


func _ready() -> void:
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	# Debug seguro
	var cena = get_tree().current_scene
	print("Portal: body entrou ->", body.name, "class:", body.get_class())
	print("Cena atual:", cena.name)

	# Só troca cena se for o jogador
	if body is CharacterBody2D:
		print("Portal: trocando para:", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Portal: ignorando, não é jogador.")
