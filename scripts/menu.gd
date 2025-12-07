extends Control

func _on_btn_jogar_pressed() -> void:
	# troca pra primeira fase do jogo
	get_tree().change_scene_to_file("res://Scenes/amazon_forest__fase_1.tscn")
	# coloque aqui o caminho da SUA primeira fase

func _on_btn_como_jogar_pressed() -> void:
	$PainelComoJogar.visible = true

func _on_btn_sair_pressed() -> void:
	get_tree().quit()


func _on_BtnJogar_pressed() -> void:
	Global.vidas = 5
	Global.moedas = 0
	Global.proxima_recompensa = 20  # só se você estiver usando
	get_tree().change_scene_to_file("res://Scenes/brasilia_fase_1.tscn")
