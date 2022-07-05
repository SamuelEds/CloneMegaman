extends KinematicBody2D

# Variáveis de estado.
enum{
	SHOOT, MOVE, JUMP, IDLE, DASH
}
var state = MOVE

# Variáveis de movimento e gravidade.
export (int) var velocidade = 5920
var velocity = Vector2.ZERO
var direcao = 1
export (int) var friccao = 600

export (int) var gravidade = 1200
onready var gravidade_original = gravidade
export (int) var forca_pulo = -900

# Obter nós e Prefabs
onready var raycasts_pulo = $Raycasts
onready var animator = $Anim
onready var sprite = $Sprite
onready var mira = $Miras/Alvo
onready var timer_bullet = $Bullet_Delay

# Variáveis para o disparo.
export (PackedScene) var bullet = preload("res://Cenas/Prefabs/Personagens/Projetil_Megaman.tscn")
# Variáveis de verificação.
var pode_atirar = true
var atirando = false

# Verificação de timers.
export (float) var timer_bullet_delay = 0.02

# Verificar tempo que o player permaneceu apertando o botão.
var button_time = 0.1
var time_bullet_charge = 0

# Propriedades.
onready var cor_original = $Sprite.modulate

# Variáveis para o Dash
const DASH_SPEED = 15000
var direcao_dash = 1
var dashing = false
onready var timer_dash_delay = $Dash_Delay
var can_dash = true

# Variáveis para Grab Wall
var grab_wall = false
onready var raycasts_grabs = $Raycasts_Grab
export (int) var grab_gravity = 1100
export (int) var forca_pulo_grab_wall = -500

func _ready():
	
	set_physics_process(true)
	
func _physics_process(delta):
	
	apply_gravity(delta)
	
	match state:
		
		IDLE:
			
			velocity.x = 0
		
		MOVE:
			
			move(delta)
		
		JUMP:
			
			jump()
		
		DASH:
			
			dash(delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_animation()

func _input(event: InputEvent):
	
	if (event.is_action_pressed("Direita") || event.is_action_pressed("Esquerda")):
		state = MOVE
	
	if Input.is_action_just_pressed("Pulo") and (verify_ground() or verify_wall()):
		state = JUMP
	
	# Quando pressiona o botão de atirar (Verifica quanto tempo o jogador deixou a tecla pressionada)
	if Input.is_action_just_pressed("Atirar"):
		atirando = true
		$Button_Delay.start(button_time)
	
	# QUando o jogador solta a tecla.
	if Input.is_action_just_released("Atirar"):
		
		# Atirar Bullet de carga quando o timer for maior que o da bullet normal.
		if time_bullet_charge >= 14:
			shoot(true)
		
		# Resetar animação e button delay.
		atirando = false
		$Button_Delay.stop()
		
		# Reset time
		time_bullet_charge = 0
	
	# Quando o Player apertar botão de Dash. Só pode dá dash quando estiver no chão ou pregado na parede.
	if Input.is_action_just_pressed("Dash") and (verify_ground() or verify_wall()):
		timer_dash_delay.start()
		state = DASH

func move(delta: float):
	
	direcao = Input.get_axis("Esquerda", "Direita")
	
	velocity.x = velocidade * direcao * delta
	
	flip()

func dash(delta):
	
	if verify_wall():
		if !sprite.flip_h:
			direcao_dash = -1
	
		else:
			direcao_dash = 1
		
		# Flipar Sprite quando estiver grudado na parede e não estiver no chão.
		if !verify_ground():
			sprite.flip_h = !sprite.flip_h
	
	if verify_ground():
		if !sprite.flip_h:
			direcao_dash = 1
		
		else:
			direcao_dash = -1
	
	# Aplicar mais velocidade para o Dash.
	velocity.x = DASH_SPEED * direcao_dash * delta
	
	# Aplicar uma força horizontal.
	if !verify_ground():
		velocity.y = forca_pulo_grab_wall / 2
	
	dashing = true

func flip():
	
	if direcao > 0:
		sprite.flip_h = false
		$Miras.scale.x = 1
		
	elif direcao < 0:
		sprite.flip_h = true
		$Miras.scale.x = -1
	
	if verify_wall():
		$Miras.scale.x = -$Miras.scale.x

# Atirar.
func shoot(bullet_is_charge: bool):
	
	if pode_atirar:
	
		# Instanciar bullets na cena.
		var bullet_instance = bullet.instance()
		
		# Adicionar bullet caso ela não existir na cena.
		if !bullet_is_charge:
			owner.add_child(bullet_instance)
		
		else:
			if Input.is_action_just_released("Atirar"):
				owner.add_child(bullet_instance)
		
		# Definindo propriedades.
		bullet_instance.global_position = mira.global_position
		
		# Definir a direção dependendo se o megaman estiver grudado na parede e não estiver no chão.
		if verify_wall() and !verify_ground():
			bullet_instance.direcao = -1 if sprite.flip_h == false else 1
		
		else:
			bullet_instance.direcao = 1 if sprite.flip_h == false else -1
		
		bullet_instance.normal_bullet = !bullet_is_charge
		bullet_instance.time_bullet_charge = time_bullet_charge
		
		pode_atirar = false
		timer_bullet.start(timer_bullet_delay)

func jump():
	
	velocity.y = forca_pulo / 2
	state = MOVE

func verify_ground():
	
	for raycasts in raycasts_pulo.get_children():
		
		if raycasts.is_colliding():
			
			return true
		
	return false

func verify_wall():
	
	for grabs in raycasts_grabs.get_children():
		
		if grabs.is_colliding():
			
			return true
	
	return false

func apply_gravity(delta: float):
	
	if verify_wall():
		gravidade = grab_gravity
	
	else:
		gravidade = gravidade_original
	
	velocity.y += gravidade * delta

func set_animation():
	
	var anim = "Idle"
	
	# Animação de movimento
	if velocity.x != 0:
		anim = "Run"
		
		# Está atirando correndo.
		if atirando:
			anim = "Run_Shoot"
	
	else:
		
		# Está atirando parado.
		if atirando:
			anim = "Idle_Shoot"
	
	# Quando o Player pular
	if velocity.y < 0 and !verify_ground():
		
		# Pular atirando
		if atirando:
			
			if verify_wall():
				anim = "Grab_Wall_Shoot"
			
			else:
				anim = "Jump_Shoot"
		
		elif verify_wall():
			anim = "Wall_Jump"
		
		else:
			anim = "Jump"
			
	
	# Quando o Player cair.
	elif velocity.y > 0 and !verify_ground():
		
		if atirando:
			
			if verify_wall():
				anim = "Grab_Wall_Shoot_Fallen"
			
			else:
				anim = "Fallen_Shoot"
		
		elif verify_wall():
			anim = "Wall_Fallen"
			
		else:
			anim = "Fall"
	
	if dashing and verify_ground():
		
		if atirando:
			anim = "Dash_Shoot"
			
		else:
			anim = "Dash"
	
	if animator.assigned_animation != anim:
		animator.play(anim)
	
func _on_Bullet_Delay_timeout():
	pode_atirar = true

func _on_Button_Delay_timeout():
	time_bullet_charge += 1
	
	# Preessionou por tempo suficiente para disparar uma bullet normal.
	if time_bullet_charge < 14:
		shoot(false)
	
	# Só vai piscar quando estiver com a carga disponível.
	else:
		sprite.modulate = Color("03fff9")
		yield(get_tree().create_timer(0.2), "timeout")
		sprite.modulate = Color("00c9ff")
		yield(get_tree().create_timer(0.2), "timeout")
		sprite.modulate = Color("98def1")
		yield(get_tree().create_timer(0.2), "timeout")
		sprite.modulate = cor_original
	

func _on_Dash_Delay_timeout():
	dashing = false
	state = MOVE
