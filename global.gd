extends Node

var moedas := 0
var moedas_coletadas := {}

var vidas: int = 5  # Player começa com 5 vidas

# ✅ Controle de recompensa por moedas
var proxima_recompensa := 20  # primeira vida com 20 moedas


func adicionar_moeda(qtd := 1) -> void:
	moedas += qtd

	# ✅ A cada 20 moedas ganha 1 vida
	if moedas >= proxima_recompensa:
		ganhar_vida()
		proxima_recompensa += 20  # próxima recompensa em +20 moedas


func ganhar_vida() -> void:
	vidas += 1
	print("Ganhou uma vida! Total:", vidas)


func perder_vida() -> void:
	if vidas > 0:
		vidas -= 1
		if vidas < 0:
			vidas = 0
