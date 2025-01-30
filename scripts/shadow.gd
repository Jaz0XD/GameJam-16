extends CharacterBody2D

@export var test:bool
@export var collisionShape:CollisionShape2D
@export var spawnDelay:float

const SPEED = 300.0
const JUMP_VELOCITY = -560.0

var grav:bool 
var ablity: String 

func  _ready() -> void: #this block is executed evertime this scene is instanced
	if test: # first check if the shadow is instanced with test mode 
		collisionShape.disabled = true
		grav = false
	else:
		collisionShape.disabled = true
		grav = false
		var spawnTimer = Timer.new()
		spawnTimer.wait_time = spawnDelay/100 # in milliseconds
		spawnTimer.one_shot = true
		spawnTimer.timeout.connect(func(): timerout())
		add_child(spawnTimer)
		spawnTimer.start()

func _input(event: InputEvent) -> void:
	pass

func _process(delta: float) -> void: #game logic
	var parent = get_parent()
	if Input.is_action_just_pressed("ablity1"):
		if ablity == "tp":
			parent.tp(global_position)
			# print(global_position)
			parent.remove_shadow(parent.shadow_instance,parent.timer)

		if ablity == "tpa":
			parent.tpanchorPos = global_position
			parent.remove_shadow(parent.shadow_instance,parent.timer)

func _physics_process(delta: float) -> void: #physics logic
	# Add the gravity.
	if not is_on_floor() and grav :
		velocity.y += 2500 * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left","right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func timerout():
	collisionShape.disabled = false
	grav = true


















