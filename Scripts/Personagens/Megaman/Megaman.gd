extends KinematicBody2D

# Variáveis de estado.
enum{
	SHOOT, MOVE, JUMP
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

func _ready():
	
	set_physics_process(true)
	
func _physics_process(delta):
	
	apply_gravity(delta)
	
	match state:
		
		MOVE:
			
			move(delta)
			
		
		SHOOT:
			
			shoot()
		
		JUMP:
			
			jump()
			
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_animation()

func _input(event: InputEvent):
	
	if event.is_action_pressed("Direita") || event.is_action_pressed("Esquerda"):
		state = MOVE
	
	if Input.is_action_just_pressed("Pulo") and verify_ground():
		state = JUMP
	
	if Input.is_action_pressed("Atirar"):
		shoot()
	
	else:
		atirando = false
	

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
func shoot():
	
	if pode_atirar:
	
		# Instanciar bullets na cena.
		var bullet_instance = bullet.instance()
		owner.add_child(bullet_instance)
		
		bullet_instance.global_position = mira.global_position
		bullet_instance.direcao = 1 if sprite.flip_h == false else -1
		
		pode_atirar = false
		atirando = true
		timer_bullet.start()

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
