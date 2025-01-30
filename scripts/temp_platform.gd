extends CharacterBody2D

@export var trigTime: float = 0.3
var T_ini_time: float = 0.0
var G_ini_time: float = 0.0
var grav_time: float = 1.0
var timer_start: bool

func _physics_process(delta: float) -> void:
	if timer_start:
		T_ini_time += delta
		G_ini_time += delta
		if T_ini_time > trigTime:
			velocity.y = 400
			move_and_slide()
		if G_ini_time > grav_time:
			queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		timer_start = true
