extends RigidBody2D

enum { INIT, ALIVE, INVULNERABLE, DEAD }

@export var engine_power: int = 500
@export var spin_power: int = 8000

var thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0
var state = INIT

@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D


func _ready():
	change_state(ALIVE)


func change_state(new_state):
	match new_state:
		INIT:
			collision_shape.set_deferred("disabled", true)
		ALIVE:
			collision_shape.set_deferred("disabled", false)
		INVULNERABLE:
			collision_shape.set_deferred("disabled", true)
		DEAD:
			collision_shape.set_deferred("disabled", true)
	state = new_state


func _process(delta: float) -> void:
	get_input()


func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return

	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power

	rotation_dir = Input.get_axis("rotate_left", "rotate_right")


func _physics_process(delta: float):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
