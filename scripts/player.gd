extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -500.0

@onready var anim = $anim as AnimatedSprite2D
var jumpPlayer = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumpPlayer = true
	else:
		jumpPlayer = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	# Verifica se o jogador está correndo (Shift pressionado)
	var is_running := Input.is_action_pressed("ui_run")
	
	# Define a velocidade base
	var current_speed = SPEED
	if is_running:
		current_speed = RUN_SPEED

	if direction:
		anim.scale.x = direction
		velocity.x = direction * current_speed

		if !jumpPlayer:
			if is_running:
				anim.play("run")
			else:
				anim.play("walk")
		else:
			anim.play("jump")
	else:
		if !jumpPlayer:
			anim.play("idle")
		else:
			anim.play("jump")

		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	if position.y >= 800:
		death()
		
	move_and_slide()
	

func death():
	anim.play("hurt")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
