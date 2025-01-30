extends CharacterBody2D

@export var gravity = 2500
@export var shadow_scene: PackedScene
@export var shadow_life = 0.05 #in minutes
@export var rayRight:RayCast2D 
@export var rayLeft:RayCast2D 

const SPEED = 340.0
const JUMP_VELOCITY = -560.0

var instanced:bool = false
var disabled:bool = false 
var facingDirection:int

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switchMode"):
		disabled = true
		instance_shadow()


func instance_shadow() :
	if not instanced:
		var shadow_instance = shadow_scene.instantiate()
		# shadow_instance.collisionShape.disabled = true	 
		add_child(shadow_instance)
		if rayLeft.is_colliding() and not rayRight.is_colliding():
			shadow_instance.global_position.x = global_position.x + 75
		elif not rayLeft.is_colliding() and rayRight.is_colliding():
			shadow_instance.global_position.x = global_position.x - 75
		elif rayRight.is_colliding() and rayLeft.is_colliding():
			shadow_instance.global_position.y = global_position.y - 75
		else: 
			if facingDirection == 0:
				facingDirection = 1
			shadow_instance.global_position.x = global_position.x + 75 * facingDirection
			# shadow_instance.collisionShape.disabled = false 
		# Start a timer to remove the shadow after n minutes
		var timer = Timer.new()
		timer.wait_time = shadow_life * 60  # Convert minutes to seconds
		timer.one_shot = true
		timer.timeout.connect(func(): remove_shadow(shadow_instance, timer))
		add_child(timer)
		timer.start()
		instanced = true

func remove_shadow(shadow_instance: Node, timer: Timer):
	if shadow_instance and instanced:
		shadow_instance.queue_free()
		shadow_instance = null

		instanced = false
	if timer:
		timer.queue_free()
	disabled = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not disabled:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")

	if direction == -1:
		facingDirection = -1
	if direction == 1:
		facingDirection = 1
	if direction and not disabled:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
