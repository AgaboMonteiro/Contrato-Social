extends Node2D
@onready var camera = $camera as Camera2D
@onready var jogador = $player as CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jogador.seguir_camera(camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reiniciar_fase():
	$reiniciar_jogo.start()

func _on_reiniciar_jogo_timeout() -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.
