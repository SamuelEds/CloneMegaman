extends Area2D


# Variáveis de movimento do Projétil.
export (int) var velocidade = 500
var direcao = 1

# Propriedades.
export (int) var dano = 4

# Variáveis de verificação.
var disparado = false
var normal_bullet = false

# Porpriedades
var bullets = ["Bullet_1", "Bullet_2", "Bullet_3"]
var bullet_index = -1
onready var animator = $Anim
onready var carga_timer = $Delay_Recarga_Bullet

func _ready():
	
	set_process(true)

func _process(delta):
		
	# Atirar com a bullet normal.
	if normal_bullet:
		disparado = true
		bullet_index = 0
	
	# Atirar com a bullet carregada.
	else:
		
		pass
	
	animator.play(bullets[bullet_index])
	
	# Quando soltar a tecla de atirar.
	if Input.is_action_just_released("Atirar"):
		disparado = true
	
	if disparado:
		global_position.x += direcao * velocidade * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Delay_Recarga_Bullet_timeout():
#	carga = true
	pass
