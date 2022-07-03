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
var bullet_index = 0
onready var animator = $Anim
onready var carga_timer = $Delay_Recarga_Bullet
onready var sprite = $Sprite
var time_bullet_charge = 0

# Propriedades de dano
export (int) var dano_charge_nivel_1 = 4
export (int) var dano_charge_nivel_2 = 9
export (int) var dano_charge_nivel_3 = 16

func _ready():
	
	set_process(true)

func _process(delta):
		
	# Atirar com a bullet normal.
	if normal_bullet:
		disparado = true
		dano = dano_charge_nivel_1
		bullet_index = 0
	
	# Atirar com a bullet carregada.
	else:
		
		# Executar a animação de acordo com o time do botão pressionado.
		
		# Executar Charge 2
		if time_bullet_charge >= 14 and time_bullet_charge < 36:
			dano = dano_charge_nivel_2
			bullet_index = 1
		
		else: # Executar Charge 2.
			dano = dano_charge_nivel_3
			bullet_index = 2
		
	
	flip()
	animator.play(bullets[bullet_index])
	
	# Quando soltar a tecla de atirar.
	if Input.is_action_just_released("Atirar"):
		disparado = true
	
	if disparado:
		global_position.x += direcao * velocidade * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func flip():
	
	if direcao > 0:
		sprite.flip_h = false
	
	else:
		sprite.flip_h = true
	

func _on_Delay_Recarga_Bullet_timeout():
#	carga = true
	pass
