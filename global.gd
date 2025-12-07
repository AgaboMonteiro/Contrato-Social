extends Node

var moedas := 0
var moedas_coletadas := {}


var vidas: int = 5  # o player começa com 5

func perder_vida() -> void:
	if vidas > 0:
		vidas -= 1
		if vidas < 0:
			vidas = 0
