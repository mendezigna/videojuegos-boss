extends KinematicBody2D

onready var sprite = $AnimatedSprite

##Moviemiento
var velocity = Vector2()
export var run_speed = 50
export var jump_speed = -50
export var gravity = 100

##Crear clones
var Clon = preload("res://Player/clon.tscn")
var colors = ["fffffb00", "ffd74b4b", "ff4f7ddf", "ffb76fd8"]
var new_clon
var clones = []
var cantLimite = 0
var count = 0

##Para cambiar al player de nuevo
var activo = true

##Para saber que esta vivo
var estaVivo = true

func setCantLimiteClones(numero):
	cantLimite = numero

func get_input():
	if (estaVivo):
		var right = Input.is_action_pressed('ui_right')
		var left = Input.is_action_pressed('ui_left')
		var jump = Input.is_action_just_pressed('ui_up')
		
		if right:
			velocity.x += run_speed
			if is_on_floor():
				sprite.play("walk")
			sprite.set_flip_h(false)
		if left:
			velocity.x -= run_speed
			if is_on_floor():
				sprite.play("walk")
			sprite.set_flip_h(true)
		if is_on_floor() and jump:
			velocity.y = jump_speed
			sprite.play("jump")
		if is_on_floor() and not left and not right and not jump:
			sprite.play("stop")
		

func desactivar():
	activo = false
	sprite.play("stop")
	$Camera2D.current = false

func activar():
	activo = true
	$Camera2D.current = true
	
func matarClone(clone):
	if (clone != new_clon):
		clone.desactivar()
	else:
		new_clon = null
		activar()
	clones.erase(clone)
	remove_clon(clone)
	

func remove_clon(clon):
	colors.append(clon.modulate.to_html())
	var temp = clon
	get_parent().remove_child(clon)
	temp.queue_free()

func agregarClon():
	if clones.size() > 0 && new_clon != null:
		new_clon.desactivar()
	new_clon = Clon.instance()
	new_clon.modulate = colors.pop_front()
	clones.append(new_clon)
	get_parent().add_child(new_clon)
	new_clon.position = $PosicionClon.global_position
	desactivar()
	new_clon.activar()

func _physics_process(delta):
	velocity.x = 0
	velocity.y += gravity * delta

	if activo:
		get_input()
	velocity = move_and_slide(velocity, Vector2(0, -1), false, 4, PI/4, false)
	
	if Input.is_action_just_pressed("clonar"):
		count +=1
		if clones.size() == cantLimite:
			print(clones.size())
			remove_clon(clones.pop_front())
		agregarClon()
	 

	if Input.is_action_just_pressed("interactuar") and clones.size() > 0:
		activar()
		new_clon.desactivar()

func morir():
	sprite.play("dead")
	estaVivo = false
	#elimina el primer clon
	for clon in clones:
		remove_clon(clon)
	activar()
