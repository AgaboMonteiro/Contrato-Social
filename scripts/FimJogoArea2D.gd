extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Colidiu com: ", body.name)
	if body.is_in_group("player"):
		print("É o player, trocando de cena...")
		get_tree().change_scene_to_file("res://Scenes/FimJogo.tscn")
