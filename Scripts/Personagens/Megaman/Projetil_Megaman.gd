extends Area2D


# Variáveis de movimento do Projétil.
export (int) var velociidade = 500
var direcao = 1

# Propriedades.
export (int) var dano = 4

func _ready():
	
	set_process(true)

func _process(delta):
	global_position.x += direcao * velociidade * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
