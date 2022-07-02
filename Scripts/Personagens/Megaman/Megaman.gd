extends KinematicBody2D

# Variáveis de estado.
enum{
	SHOOT, MOVE, JUMP, IDLE
}
var state = MOVE

# Variáveis de movimento e gravidade.
export (int) var velocidade = 5920
var velocity = Vector2.ZERO
var direcao = 1
export (int) var friccao = 600

export (int) var gravidade = 1200
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
var time = 0

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
			
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_animation()

func _input(event: InputEvent):
	
	if event.is_action_pressed("Direita") || event.is_action_pressed("Esquerda"):
		state = MOVE
	
	
	if Input.is_action_just_pressed("Pulo") and verify_ground():
		state = JUMP
	
	if Input.is_action_just_pressed("Atirar"):
		atirando = true
		$Button_Delay.start(button_time)
	
	if Input.is_action_just_released("Atirar"):
		
		shoot(true)
		atirando = false
		$Button_Delay.stop()
		
		# Reset time
		time = 0
	

func move(delta: float):
	
	direcao = Input.get_axis("Esquerda", "Direita")
	
	velocity.x = velocidade * direcao * delta
	
	flip()

func flip():
	
	if direcao > 0:
		sprite.flip_h = false
		$Miras.scale.x = 1
	
	elif direcao < 0:
		sprite.flip_h = true
		$Miras.scale.x = -1

# Atirar.
func shoot(bullet_is_charge: bool):
	
	if pode_atirar:
	
		# Instanciar bullets na cena.
		var bullet_instance = bullet.instance()
		
		# Adicionar bullet caso ela não existir na cena.
		if !owner.has_node(bullet_instance.name) and !bullet_is_charge:
			owner.add_child(bullet_instance)
		
		else:
			
			if !owner.has_node(bullet_instance.name) and Input.is_action_just_released("Atirar"):
				owner.add_child(bullet_instance)
				print("Carga")
			
		bullet_instance.global_position = mira.global_position
		bullet_instance.direcao = 1 if sprite.flip_h == false else -1
		bullet_instance.normal_bullet = !bullet_is_charge
		
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
	
func apply_gravity(delta: float):
	
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
	
	if velocity.y < 0 and !verify_ground():
		anim = "Jump"
	
	elif velocity.y > 0 and !verify_ground():
		anim = "Fall"
	
	if animator.assigned_animation != anim:
		animator.play(anim)
		

func _on_Bullet_Delay_timeout():
	pode_atirar = true

func _on_Button_Delay_timeout():
	time += 1
	
	# Preessionou por tempo suficiente para disparar uma bullet normal.
	if time < 14:
		shoot(false)
	
	
	
