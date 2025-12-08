extends CharacterBody2D

enum FazendeiroState{
	walk,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var walk_detector: RayCast2D = $WalkDetector   # <- detector de parede
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var body_collision: CollisionShape2D = $CollisionShape2D  # <- colisão do corpo


const SPEED = 50.0
const DEATH_WAIT := 1.0   # tempo da morte (igual player, se quiser)

var status : FazendeiroState
var direction = 1

func _ready() -> void:
	go_to_walk_state()
	add_to_group("inimigos")

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

	# VERIFICAÇÃO CORRETA
	if walk_detector.is_colliding():
		scale.x *= -1
		direction *= -1

	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1

func go_to_dead_state() -> void:
	if status == FazendeiroState.dead:
		return

	status = FazendeiroState.dead
	anim.play("dead")
	velocity = Vector2.ZERO

	# 🔻 AQUI PARA DE COLIDIR 🔻
	# desliga a colisão física do inimigo
	body_collision.set_deferred("disabled", true)

	# desliga a hitbox (para não dar mais dano no player)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	# 🔺 ---------------------- 🔺

	# espera a animação de morte / tempo de morte
	await get_tree().create_timer(DEATH_WAIT).timeout

	# depois de morto, some (ou faz outra coisa se quiser)
	queue_free()

func dead_state(delta: float) -> void:
	# só aplica gravidade enquanto está morto
	velocity.y += get_gravity().y * delta
