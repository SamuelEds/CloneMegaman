extends Area2D


# Variáveis de movimento do Projétil.
export (int) var velociidade = 500
var direcao = 1

# Propriedades.
export (int) var dano = 4

# Variáveis de verificação.
var disparado = false
var carga = true

# Porpriedades
var bullets = ["Bullet_1", "Bullet_2", "Bullet_3", "Bullet_4", "Bullet_5", "Bullet_6"]
var bullet_index = -1
onready var animator = $Anim
onready var carga_timer = $Delay_Recarga_Bullet

func _ready():
	
	set_process(true)

func _process(delta):
	
	if carga:
		
		# Cálculo para as bullets
		bullet_index = (bullet_index + 1) % bullets.size()
		animator.play(bullets[bullet_index])
		
		carga = false
		carga_timer.start()
	
	# Quando soltar a tecla de atirar.
	if Input.is_action_just_released("Atirar"):
		disparado = true
	
	if disparado:
		global_position.x += direcao * velociidade * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Delay_Recarga_Bullet_timeout():
	carga = true
