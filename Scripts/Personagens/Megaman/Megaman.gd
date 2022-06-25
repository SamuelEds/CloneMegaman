extends KinematicBody2D

# Variáveis de estado.
enum{
	SHOOT, IDLE, MOVE, JUMP
}
var state = IDLE

# Variáveis de movimento e gravidade.
export (int) var velocidade = 600
var velocity = Vector2.ZERO
var direcao = 1

export (int) var gravidade = 1200
export (int) var forca_pulo = 1500

func _ready():
	
	set_physics_process(true)
	
func _physics_process(delta):
	
	apply_gravity(delta)
	
	match state:
		
		IDLE:
			
			pass
		
		MOVE:
			
			move()
			
		
		SHOOT:
			
			pass
		
		JUMP:
			jump()
			
	
	velocity = move_and_slide(velocity, Vector2.UP)
	print(velocity.y)
	
	set_animation()

func _input(event: InputEvent):
	
	if Input.is_action_pressed("Direita") || Input.is_action_pressed("Esquerda"):
		
		state = MOVE
	
	if Input.is_action_just_pressed("Pulo"):
		state = JUMP
	

func move():
	
	direcao = Input.get_axis("Esquerda", "Direita")
	
	velocity.x = direcao * velocidade
	
	if velocity.x == 0:
		state = IDLE

func jump():
	
	velocity.y = forca_pulo / 2

func apply_gravity(delta: float):
	
	velocity.y += gravidade * delta

func set_animation():
	
	
	pass
