extends Area2D

# Caminho padrão da próxima fase (fase 2 -> fase 3)
@export var next_scene_path : String = "res://Scenes/brasilia_fase_3.tscn"

func _ready() -> void:
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Debug
	var cena = get_tree().current_scene
	print("Portal (fase 2): body entrou ->", body.name, "class:", body.get_class())
	print("Cena atual:", cena.name)

	# Só troca cena se for o jogador (ajuste se sua classe for diferente)
	if body is CharacterBody2D:
		print("Portal (fase 2): trocando para:", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Portal (fase 2): ignorando, não é jogador.")
