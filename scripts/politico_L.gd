extends CharacterBody2D

enum FazendeiroState {
	walk,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var walk_detector: RayCast2D = $WalkDetector
@onready var ground_detector: RayCast2D = $GroundDetector

const SPEED = 50.0
const VIDA_MAX = 5   # ✅ precisa de 5 ataques

var status: FazendeiroState
var direction = 1
var vida = VIDA_MAX

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		FazendeiroState.walk:
			walk_state(delta)
		FazendeiroState.dead:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = FazendeiroState.walk
	anim.play("walk")

func walk_state(_delta):
	velocity.x = SPEED * direction

	if walk_detector.is_colliding():
		virar()

	if not ground_detector.is_colliding():
		virar()

func virar():
	scale.x *= -1
	direction *= -1

# ✅ FUNÇÃO DE DANO — CHAME ESSA FUNÇÃO QUANDO ATACAR
func receber_dano(dano := 1) -> void:
	if status == FazendeiroState.dead:
		return

	vida -= dano

	if vida <= 0:
		morrer()

func morrer() -> void:
	status = FazendeiroState.dead
	velocity.x = 0
	anim.play("dead")  # animação de morte (se tiver)

func dead_state(_delta):
	pass
