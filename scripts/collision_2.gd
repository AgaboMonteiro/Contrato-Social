extends Area2D

func _ready() -> void:
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node2D) -> void:
	print("collision2 encostou em:", body.name)  # DEBUG

	if body.is_in_group("inimigos"):
		print("É inimigo, matando player...")
		var player := get_parent() as CharacterBody2D
		player.go_to_dead_state()
