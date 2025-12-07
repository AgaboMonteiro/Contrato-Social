extends Area2D

var moeda := 1
var id_moeda: String

func _ready() -> void:
	# Nome da cena atual (fase) + nome do node
	var nome_fase = get_tree().current_scene.name
	id_moeda = "%s_%s" % [nome_fase, name]

	# Se essa moeda já foi coletada nessa fase, some
	if Global.moedas_coletadas.has(id_moeda):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	$anim.play("coletar")
	$colisao.call_deferred("queue_free")

	Global.adicionar_moeda(moeda)
	Global.moedas_coletadas[id_moeda] = true

func _on_anim_animation_finished() -> void:
	queue_free()
