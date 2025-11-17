extends CharacterBody2D

# Estados do Player
enum PlayerState {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	HURT,
	DEAD
}

@onready var anim: AnimatedSprite2D = $anim

# Configurações
const SPEED = 100.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -500.0

# Velocidade turbo do pulo
const JUMP_HORIZONTAL_MULTIPLIER = 1   # quanto maior, mais rápido no ar
const JUMP_VERTICAL_MULTIPLIER = 1      # pulo mais forte ao correr
const AIR_ACCEL = 100                  # quão rápido acelera no ar

var state: PlayerState = PlayerState.IDLE
var is_attacking = false
var direction := 0.0


func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:

	# SE ESTIVER MORTO — nada funciona
	if state == PlayerState.DEAD:
		velocity.x = 0
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return

	# Lê direções
	direction = Input.get_axis("ui_left", "ui_right")

	# ESTADOS
	match state:
		PlayerState.IDLE:
			idle_state(delta)

		PlayerState.WALK:
			walk_state(delta)

		PlayerState.RUN:
			run_state(delta)

		PlayerState.JUMP:
			jump_state(delta)

		PlayerState.FALL:
			fall_state(delta)

		PlayerState.ATTACK:
			attack_state(delta)

		PlayerState.HURT:
			hurt_state(delta)
			
		PlayerState.DEAD:
			dead_state(delta)

	move_and_slide()

	# Morte por queda
	if position.y >= 800:
		go_to_dead_state()


# ============================================================
#   ESTADOS
# ============================================================

func go_to_idle_state():
	state = PlayerState.IDLE
	anim.play("idle")

func idle_state(delta):
	apply_gravity(delta)
	move_horizontal(delta)

	if direction != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("ui_attack"):
		go_to_attack_state()
		return


func go_to_walk_state():
	state = PlayerState.WALK
	anim.play("walk")

func walk_state(delta):
	apply_gravity(delta)
	move_horizontal(delta)

	if direction == 0:
		go_to_idle_state()
		return

	if Input.is_action_pressed("ui_run"):
		go_to_run_state()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		go_to_jump_state()
		return

	if not is_on_floor():
		go_to_fall_state()
		return

	if Input.is_action_just_pressed("ui_attack"):
		go_to_attack_state()
		return


func go_to_run_state():
	state = PlayerState.RUN
	anim.play("run")

func run_state(delta):
	apply_gravity(delta)
	move_horizontal(delta, RUN_SPEED)

	if not Input.is_action_pressed("ui_run"):
		go_to_walk_state()
		return

	if direction == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		go_to_jump_state()
		return

	if not is_on_floor():
		go_to_fall_state()
		return

	if Input.is_action_just_pressed("ui_attack"):
		go_to_attack_state()
		return


# ============================================================
#   PULO TURBO (correndo ele pula MUITO longe e rápido)
# ============================================================

func go_to_jump_state():
	state = PlayerState.JUMP
	anim.play("jump")

	# Pulo vertical mais forte quando estiver correndo
	if Input.is_action_pressed("ui_run"):
		velocity.y = JUMP_VELOCITY * JUMP_VERTICAL_MULTIPLIER
	else:
		velocity.y = JUMP_VELOCITY

	# PULO HORIZONTAL TURBO (ao correr)
	if Input.is_action_pressed("ui_run") and direction != 0:
		velocity.x = direction * (RUN_SPEED * JUMP_HORIZONTAL_MULTIPLIER)


func jump_state(delta):
	apply_gravity(delta)

	# ACELERAÇÃO NO AR (ao correr)
	if Input.is_action_pressed("ui_run") and direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * (RUN_SPEED * JUMP_HORIZONTAL_MULTIPLIER),
			AIR_ACCEL * delta
		)
	else:
		move_horizontal(delta)

	if velocity.y > 0:
		go_to_fall_state()
		return


func go_to_fall_state():
	state = PlayerState.FALL
	anim.play("jump")

func fall_state(delta):
	apply_gravity(delta)

	# Aceleração turbo também na queda
	if Input.is_action_pressed("ui_run") and direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * (RUN_SPEED * JUMP_HORIZONTAL_MULTIPLIER),
			AIR_ACCEL * delta
		)
	else:
		move_horizontal(delta)

	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return


# ============================================================
#   ATAQUE
# ============================================================

func go_to_attack_state():
	if state == PlayerState.ATTACK:
		return

	state = PlayerState.ATTACK
	is_attacking = true
	anim.play("attack1")
	attack_timeout()

func attack_state(delta):
	apply_gravity(delta)
	move_horizontal(delta)

func attack_timeout() -> void:
	await get_tree().create_timer(0.35).timeout
	is_attacking = false
	go_to_idle_state()


# ============================================================
#   DANO / MORTE
# ============================================================

func go_to_hurt_state():
	if state == PlayerState.HURT:
		return

	state = PlayerState.HURT
	anim.play("hurt")
	velocity = Vector2.ZERO

	await get_tree().create_timer(1.0).timeout
	go_to_dead_state()


func hurt_state(delta):
	apply_gravity(delta)


func go_to_dead_state():
	state = PlayerState.DEAD
	anim.play("dead")
	velocity = Vector2.ZERO

	
func dead_state(delta):
	pass


# ============================================================
#   MOVIMENTO / GRAVIDADE
# ============================================================

func move_horizontal(delta, custom_speed := SPEED):
	if direction != 0:
		velocity.x = direction * custom_speed
		anim.flip_h = direction < 0
	else:
		velocity.x = 0

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func _on_hit_box_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		#inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		#player morre
		go_to_dead_state()
