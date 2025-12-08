extends Area2D

var moeda := 1
var id_moeda: String

var tempo := 0.0
var pos_inicial: Vector2

@export var amplitude := 20.0 # quanto ela sobe/desce
@export var velocidade := 3.0 # quão rápido ela balança

func _ready() -> void:
	# guarda a posição inicial pra usar como centro do movimento
	pos_inicial = position

	# Nome da cena atual (fase) + nome do node
	var nome_fase = get_tree().current_scene.name
	id_moeda = "%s_%s" % [nome_fase, name]

	# Se essa moeda já foi coletada nessa fase, some
	if Global.moedas_coletadas.has(id_moeda):
		queue_free()

func _process(delta: float) -> void:
	tempo += delta * velocidade
	# meia lua vertical (sobe e desce)
	position.y = pos_inicial.y + sin(tempo) * amplitude
	# se quiser balançar pro lado também, descomenta:
	# position.x = pos_inicial.x + cos(tempo) * amplitude * 0.5

func _on_body_entered(body: Node2D) -> void:
	$anim.play("coletar")
	$colisao.call_deferred("queue_free")

	Global.adicionar_moeda(moeda)
	Global.moedas_coletadas[id_moeda] = true

func _on_anim_animation_finished() -> void:
	queue_free()
