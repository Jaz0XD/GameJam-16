#--------------(VARIABLESAND CONSTANTS)-----------------#

extends CharacterBody2D

@export var cameraOffset: Vector2 = Vector2(138,-87)
@export var gravity:float = 2500.0 
@export var attackRAY:RayCast2D 

@onready var testMesh = $visuals/MeshInstance2D
@onready var cameraController = $cameraController
@onready var Stexture = $cameraController/TextureRect


const SPEED = 170.0
const JUMP_VELOCITY = -580.0



var facingDirection:int

#--------------(MAIN LOGIC)-----------------#
func _physics_process(delta: float) -> void:

	#--------------(BASIC CHARACTER CONTROLLER)-----------------#

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():

		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	if direction == -1:
		facingDirection = -1
	elif direction == 1:
		facingDirection = 1

	if direction != 0:
		attackRAY.scale.x = direction
		$visuals.scale.x = direction

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _process(delta: float) -> void:

	#--------------(GAME LOGIC)-----------------#

	cameraController.targetCharacter = self

	if attackRAY.is_colliding():#if a raycast is colliding with the enemy and a key is pressed then apply damage to that enemy
		var body = attackRAY.get_collider()
		if body:
			if body.is_in_group("ENEMY") and Input.is_action_just_pressed("attack"):
				body.damage(1)

func physics(calculate: bool):# enable or disable physics engine
	set_physics_process(calculate)
