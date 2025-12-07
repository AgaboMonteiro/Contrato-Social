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
@onready var remote = $remote as RemoteTransform2D

# Configurações (ajuste ao gosto)
const SPEED := 150.0
const RUN_SPEED := 220.0
const JUMP_VELOCITY := -480.0
const AIR_ACCEL := 1500.0

# Tempo de espera antes de executar lógica de morte
const DEATH_WAIT := 1.0

var state: PlayerState = PlayerState.IDLE
var is_attacking := false
var direction := 0.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Se estiver morto, apenas aplique gravidade e deixe cair
	if state == PlayerState.DEAD:
		velocity.x = 0
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return

	# entradas
	direction = Input.get_axis("ui_left", "ui_right")
	var holding_run := Input.is_action_pressed("ui_run")

	# máquina de estados
	match state:
		PlayerState.IDLE:
			idle_state(delta, holding_run)
		PlayerState.WALK:
			walk_state(delta, holding_run)
		PlayerState.RUN:
			run_state(delta, holding_run)
		PlayerState.JUMP:
			jump_state(delta, holding_run)
		PlayerState.FALL:
			fall_state(delta, holding_run)
		PlayerState.ATTACK:
			attack_state(delta, holding_run)
		PlayerState.HURT:
			hurt_state(delta)

	# aplicar movimento final
	move_and_slide()

	# morte por queda (ajuste o 800 se precisar)
	if position.y >= 800 and state != PlayerState.DEAD:
		go_to_dead_state()

# -------------------- Estados --------------------

func go_to_idle_state() -> void:
	state = PlayerState.IDLE
	anim.play("idle")

func idle_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)
	ground_move(holding_run)

	if direction != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("ui_attack"):
		go_to_attack_state()
		return

func go_to_walk_state() -> void:
	state = PlayerState.WALK
	anim.play("walk")

func walk_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)
	ground_move(holding_run)

	if direction == 0:
		go_to_idle_state()
		return

	if holding_run:
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

func go_to_run_state() -> void:
	state = PlayerState.RUN
	anim.play("run")

func run_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)
	ground_move(holding_run)

	if not holding_run:
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

# -------------------- Pulo --------------------

func go_to_jump_state() -> void:
	state = PlayerState.JUMP
	anim.play("jump")

	var holding_run := Input.is_action_pressed("ui_run")
	if holding_run:
		velocity.y = JUMP_VELOCITY * 1.10
	else:
		velocity.y = JUMP_VELOCITY

	if direction != 0:
		anim.flip_h = direction < 0

func jump_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)

	var target_speed := RUN_SPEED if holding_run else SPEED

	if direction != 0:
		var target := direction * target_speed
		velocity.x = move_toward(velocity.x, target, (AIR_ACCEL * 0.6) * delta)
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, (AIR_ACCEL * 0.6) * delta)

	if velocity.y > 0:
		go_to_fall_state()
		return

func go_to_fall_state() -> void:
	state = PlayerState.FALL
	anim.play("fall")

func fall_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)

	var target_speed := RUN_SPEED if holding_run else SPEED

	if direction != 0:
		var target := direction * target_speed
		velocity.x = move_toward(velocity.x, target, (AIR_ACCEL * 0.6) * delta)
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, (AIR_ACCEL * 0.6) * delta)

	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

# -------------------- Ataque --------------------

func go_to_attack_state() -> void:
	if state == PlayerState.ATTACK:
		return
	state = PlayerState.ATTACK
	is_attacking = true
	anim.play("attack1")
	attack_timeout()

func attack_state(delta: float, holding_run: bool) -> void:
	apply_gravity(delta)
	# mantém controle horizontal leve
	ground_move(holding_run)

func attack_timeout() -> void:
	# duração do ataque (ajuste conforme sua animação)
	await get_tree().create_timer(0.35).timeout

	if is_on_floor():
		if direction == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
	else:
		go_to_fall_state()
	
	

# -------------------- Dano / Morte --------------------

func go_to_hurt_state() -> void:
	if state == PlayerState.HURT or state == PlayerState.DEAD:
		return
	state = PlayerState.HURT
	anim.play("hurt")
	velocity = Vector2.ZERO

	# tempo de invencibilidade / animação de hit
	await get_tree().create_timer(0.8).timeout

	# depois do hurt, vai para morto
	go_to_dead_state()

func hurt_state(_delta: float) -> void:
	apply_gravity(_delta)

func go_to_dead_state() -> void:
	if state == PlayerState.DEAD:
		return

	state = PlayerState.DEAD
	anim.play("dead")
	velocity = Vector2.ZERO

	# espera animação de morte
	await get_tree().create_timer(DEATH_WAIT).timeout

	# perde 1 vida (se ainda tiver)
	if Global.vidas > 0:
		Global.perder_vida()

	# se ainda sobrou vida, reinicia fase
	if Global.vidas > 0:
		if get_tree().current_scene and get_tree().current_scene.has_method("reiniciar_fase"):
			get_tree().current_scene.reiniciar_fase()
		else:
			get_tree().reload_current_scene()
	else:
		# sem vidas: some o player, HUD mostra GAME OVER
		queue_free()

# -------------------- Física / util --------------------

func ground_move(holding_run: bool) -> void:
	var speed := RUN_SPEED if holding_run else SPEED
	if direction != 0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
	else:
		velocity.x = 0

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# -------------------- Câmera --------------------

func seguir_camera(camera):
	remote.remote_path = camera.get_path()
