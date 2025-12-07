extends Control

@onready var contador_moeda: Label = $"../control/container/moedas_container/contador_moeda"
@onready var contador_vida:  Label = $vida_container/vida/anim/contador_vida
@onready var game_over_label: Label = $game_over_label

   # crie esse Label na cena

func _ready() -> void:
	if game_over_label:
		game_over_label.visible = false
	_atualizar_hud()

func _process(delta: float) -> void:
	_atualizar_hud()

	# quando chegar em 0 vidas, mostra "GAME OVER"
	if Global.vidas <= 0 and game_over_label:
		game_over_label.visible = true

func _atualizar_hud() -> void:
	if contador_moeda:
		contador_moeda.text = "%04d" % Global.moedas
	if contador_vida:
		contador_vida.text = "%02d" % Global.vidas
