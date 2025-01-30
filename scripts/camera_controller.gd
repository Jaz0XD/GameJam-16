extends Node2D

@export var texVisible:bool = false
@export var posSmooth:bool = true


var targetCharacter: Node
var cameraOffset: Vector2 
var maxOffset: float = 240
var smoothFactor: float = 3.5 
var xoffset: float = 0.0

@onready var camera = $Camera2D
@onready var camtexture = $Control/TextureRect
@onready var camcontrol = $Control

func _ready() -> void:
	targetCharacter = get_parent()

func _process(delta: float) -> void:
	
	if posSmooth:
		camera.position_smoothing_enabled = true
	else:
		camera.position_smoothing_enabled = false

	camtexture.visible = true if texVisible else false
	camcontrol.position = camera.get_screen_center_position() - (camcontrol.size / 2)


	if Input.is_action_just_pressed("jump"):
		var targetposition: Vector2
		targetposition = targetCharacter.global_position
		global_position.y = -targetposition.y

	camera.offset = Vector2(0,0)
	cameraOffset.y = -130
	if targetCharacter:
		global_position = targetCharacter.global_position
	
	var targetDirection = sign(targetCharacter.velocity.x)
	var targetOffset = targetDirection * maxOffset
	
	xoffset = lerp(xoffset,targetOffset,smoothFactor / 100)
	
	cameraOffset.x = xoffset
	camera.offset = cameraOffset


func level2Entry():
	posSmooth = true
