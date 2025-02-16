extends RigidBody2D

enum { INIT, ALIVE, INVULNERABLE, DEAD }

@export var engine_power: int = 500
@export var spin_power: int = 8000

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25

var can_shoot = true

var thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0
var state = INIT

var screensize = Vector2.ZERO

@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D
@onready var gun_cooldown = $GunCooldown
@onready var laser_sound = $LaserSound


func _ready():
	change_state(ALIVE)

	gun_cooldown.wait_time = fire_rate
	screensize = get_viewport_rect().size


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

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()


func shoot():
	if state == INVULNERABLE:
		return
	laser_sound.play()
	can_shoot = false
	gun_cooldown.start()
	
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)


func _physics_process(delta: float):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power


func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform


func _on_gun_cooldown_timeout() -> void:
	can_shoot = true
