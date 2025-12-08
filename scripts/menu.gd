extends Control

func _ready() -> void:
	$PainelComoJogar.visible = false


func _on_btn_jogar_pressed() -> void:
	# Reseta os dados do jogo ao iniciar
	Global.vidas = 5
	Global.moedas = 0
	Global.proxima_recompensa = 20  # só se você estiver usando

	# Troca pra primeira fase
	get_tree().change_scene_to_file("res://Scenes/amazon_forest__fase_1.tscn")
	# ou:
	# get_tree().change_scene_to_file("res://Scenes/brasilia_fase_1.tscn")


func _on_btn_como_jogar_pressed() -> void:
	# Mostra o painel de instruções
	$PainelComoJogar.visible = true


func _on_btn_voltar_pressed() -> void:
	# Esconde o painel de instruções
	$PainelComoJogar.visible = false


func _on_btn_sair_pressed() -> void:
	get_tree().quit()
