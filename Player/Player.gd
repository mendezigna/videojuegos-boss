extends KinematicBody2D

onready var sprite = $AnimatedSprite
onready var interface = $Perdiste/GameOver
onready var interfaceLabel = $Perdiste/GameOver/GameOver
onready var interfaceTimer = $Perdiste/GameOver/MostrarReloj
onready var playAgain = $Perdiste/GameOver/Button
onready var collision = $CollisionShape2D

##Moviemiento
var velocity = Vector2()
export var run_speed = 50
export var jump_speed = -50
export var gravity = 98

##Crear clones
var Clon = preload("res://Player/clon.tscn")
var Orbe = preload("res://Player/Orbe.tscn")
var colors = ["ff3737", "ff4f7ddf", "00ff00", "ffb76fd8"]
var orbes = []
var new_clon
var jumping = false
var clones = []
var cantLimite = 0
var count = 0
var index = 0;
##Para cambiar al player de nuevo
var activo = true

##Para saber que esta vivo
var estaVivo = true

func _ready():
	interface.hide()
	orbes = [$Orbe1, $Orbe2, $Orbe3, $Orbe4]

##Se limita la cantidad de clones
func setCantLimiteClones(numero):
	cantLimite = numero
	setLabelText()

func setLabelText():
	$CanvasLayer/Label.text = "Restantes: " + str(cantLimite - clones.size())

func _physics_process(delta):
	velocity.x = 0
	var snap = 3
	siEstaActivo()
	if estaVivo:
		if velocity.y != 0:
			snap = Vector2(0,0)
			caer()
		elif velocity.x == 0 and sprite.animation != "summon" and sprite.animation != "land":
			parar()
		clonar()
		manejarPlayer()
		reiniciarClones()
	# warning-ignore:return_value_discarded
	move_and_slide_with_snap(velocity, Vector2.DOWN * snap, Vector2(0, -1), false)
	siEstaEnElPiso(delta)
	interfaceTimer.text = "Revivir en: " + str((ceil(get_tree().get_nodes_in_group("time")[0].get_time_left())))

func siEstaActivo():
	if activo:
		get_input()

func siEstaEnElPiso(delta):
	if is_on_floor():
		velocity.y = 0
		if jumping and estaVivo:
			sprite.play("land")
			sprite.offset.x = 0
			sprite.offset.y = 0
			jumping = false
			$CPUParticles2D.emitting = true 
	else:
		velocity.y += gravity * delta

func clonar():
	if Input.is_action_just_pressed("clonar") and clones.size() < cantLimite and is_on_floor():
			agregarClon()
			sprite.play("summon")

func manejarPlayer():
	if Input.is_action_just_pressed("interactuar") and clones.size() > 0:
			activar()
			if new_clon != null:
				new_clon.desactivar()

func reiniciarClones():
	if Input.is_action_just_pressed("reiniciar_clones") and clones.size() > 0:
			remover_clones()

func parar():
	sprite.play("stop")
	sprite.offset.x = 0
	sprite.offset.y = 0

func caer():
	if velocity.y > 0 :
		sprite.play("falling")
		if velocity.x > 0 or !sprite.flip_h:
			sprite.offset.x = -2
		elif velocity.x < 0 or sprite.flip_h:
			sprite.offset.x = 2
		sprite.offset.y = 3.5

func get_input():
	if (estaVivo):
		var right = Input.is_action_pressed('ui_right')
		var left = Input.is_action_pressed('ui_left')
		var jump = Input.is_action_just_pressed('ui_up')
		if right:
			velocity.x += run_speed
			if is_on_floor() and sprite.animation != "land" and sprite.animation != "summon":
				sprite.play("walk")
				sprite.offset.x = -3
				sprite.offset.y = 0
			sprite.set_flip_h(false)
		if left:
			velocity.x -= run_speed
			if is_on_floor() and sprite.animation != "land" and sprite.animation != "summon":
				sprite.play("walk")
				sprite.offset.x = 3
				sprite.offset.y = 0
			sprite.set_flip_h(true)
		if is_on_floor() and jump:
			velocity.y = jump_speed
			jumping = true
			sprite.play("jump")
			sprite.offset.x = 0
			sprite.offset.y = 3
		if is_on_floor() and not left and not right and not jump and sprite.animation != "land" and sprite.animation != "summon":
			sprite.play("stop")
			sprite.offset.x = 0
			sprite.offset.y = 0

func agregarClon():
	if clones.size() > 0 && new_clon != null:
		new_clon.desactivar()
	new_clon = Clon.instance()
	new_clon.cambiarColor(colors.pop_front())
	orbes[clones.size()].hide()
	clones.append(new_clon)
	get_parent().add_child(new_clon)
	new_clon.position = $PosicionClon.global_position
	desactivar()
	new_clon.activar()
	setLabelText()

func desactivar():
	activo = false
	if sprite.animation != "land" and sprite.animation != "summon":
		sprite.play("stop")
		sprite.offset.x = 0
		sprite.offset.y = 0

func remover_clones():
	for clon in get_tree().get_nodes_in_group("clon"):
		clon.desactivar()
		remove_clon(clon)

func remove_clon(clon):
	if clon == new_clon:
		new_clon = null
	colors.append(clon.modulate.to_html())
	clones.erase(clon)
	orbes[clones.size()].show()
	clon.morir()
	setLabelText()
	activar()

func activar():
	activo = true

func morir():
	if estaVivo:
		sprite.play("dead")
		estaVivo = false
		remover_clones()
		interface.show()
		playAgain.hide()
		pararMusica()
		$AudioMuerte.play()
	
func win():
	interfaceLabel.text = "YOU WIN!!"
	interface.show()
	desactivar()
	interfaceTimer.hide()
	pararMusica()
	
func pararMusica():
	$AudioFondo.stop()

func _on_AnimatedSprite_animation_finished():
	if sprite.animation != "dead" and sprite.animation != "walk" and sprite.animation != "jump" and sprite.animation != "falling":
		sprite.play("stop")
		sprite.offset.x = 0
		sprite.offset.y = 0
	sprite.stop()
