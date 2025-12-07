extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var time := 0.0

func _ready() -> void:
	anim.play("idle")  # toca a animação do fogo

func _process(delta: float) -> void:
	time += delta
	position.x += sin(time * 8) * 0.1    # balança o fogo
