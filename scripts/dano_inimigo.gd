extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		# Faz o player quicar pra cima
		body.velocity.y = body.JUMP_VELOCITY
		
		# Em vez de sumir, manda o inimigo morrer com animação
		if owner.has_method("go_to_dead_state"):
			owner.go_to_dead_state()
