#--------------(VARIABLESAND CONSTANTS)-----------------#

extends CharacterBody2D

@export var cameraOffset: Vector2 = Vector2(138,-87)
@export var gravity:float = 2000.0 
@export var shadow_scene: PackedScene
@export var shadow_offset: int = 75
@export var shadow_life = 0.05 #in minutes
@export var rayRight:RayCast2D 
@export var rayLeft:RayCast2D 
@export var attackRAY:RayCast2D 

@onready var testMesh = $visuals/MeshInstance2D
@onready var cameraController = $cameraController
@onready var tpanchorScene = preload("res://scenes/tpanchor_sprite.tscn")

const SPEED = 340.0
const JUMP_VELOCITY = -560.0


var tpanchorPos = null
var selectedAblity: String = "tpa"
var shadow_instance
var timer
var instanced:bool = false
var disabled:bool = false 
var facingDirection:int

#--------------(MAIN LOGIC)-----------------#
func _physics_process(delta: float) -> void:

	#--------------(BASIC CHARACTER CONTROLLER)-----------------#

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not disabled:

		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	if direction == -1:
		facingDirection = -1
	elif direction == 1:
		facingDirection = 1

	if direction != 0:
		attackRAY.scale.x = direction
		$visuals.scale.x = direction

	if direction and not disabled:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _process(delta: float) -> void:

	#--------------(GAME LOGIC)-----------------#

	cameraController.targetCharacter = shadow_instance if instanced else self

	if attackRAY.is_colliding():#if a raycast is colliding with the enemy and a key is pressed then apply damage to that enemy
		var body = attackRAY.get_collider()
		if body:
			if body.is_in_group("ENEMY") and Input.is_action_just_pressed("attack"):
				body.damage(1)

	if Input.is_action_just_pressed("switchMode"):# instance the shadow controller when this key is pressed
		disabled = true
		if tpanchorPos:
			tpanchorPos = null
		instance_shadow(selectedAblity)

	if Input.is_action_just_pressed("ablity1"):
		if tpanchorPos:# if tpanchorpos has a value that is not equal to null then
			tp(tpanchorPos)# teleport player to that position
			tpanchorPos = null # set it back to null 


	if disabled and is_on_floor():
		physics(false)
	else:
		physics(true)

func instance_shadow(ablity) :

	#--------------(instance a shadow controller )-----------------#

	if not instanced: # execute only when a shadow is not instanced
		$cameraController.texVisible = true
		shadow_instance = shadow_scene.instantiate() # instance the shadow scene 
		# shadow_instance.collisionShape.disabled = true	 
		add_child(shadow_instance) # add that shadow scene as a child of the player controller node

		# logic to select the spawn position based on the environment
		shadow_instance.ablity = ablity

		if rayLeft.is_colliding() and not rayRight.is_colliding():
			shadow_instance.global_position.x = global_position.x + shadow_offset
		elif not rayLeft.is_colliding() and rayRight.is_colliding():
			shadow_instance.global_position.x = global_position.x - shadow_offset
		elif rayRight.is_colliding() and rayLeft.is_colliding():
			shadow_instance.global_position.y = global_position.y - shadow_offset
		else: 
			if facingDirection == 0:
				facingDirection = 1
			shadow_instance.global_position.x = global_position.x + shadow_offset * facingDirection
			# shadow_instance.collisionShape.disabled = false 
		# Start a timer to remove the shadow after n minutes
		timer = Timer.new()
		timer.wait_time = shadow_life * 60  # Convert minutes to seconds
		timer.one_shot = true
		timer.timeout.connect(func(): remove_shadow(shadow_instance, timer))
		add_child(timer)
		timer.start()
		instanced = true #instanced is now true so no other shadow can be instanced by accidently calling this function

func remove_shadow(S_shadow_instance: Node, S_timer: Timer):

	#--------------(remove that shadow istance)-----------------#
	
	cameraController.texVisible = false

	if S_shadow_instance and instanced:# revert the changes done in the instance_shadow(scene)
		S_shadow_instance.queue_free()
		S_shadow_instance = null
		instanced = false

	if S_timer:
		S_timer.queue_free()
	disabled = false 

func tp(pos):# a function to handle the teleport mechanic
	global_position = pos 
	# print(global_position)

func physics(calculate: bool):# enable or disable physics engine
	set_physics_process(calculate)
