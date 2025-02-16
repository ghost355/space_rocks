extends RigidBody2D  # тело с поддержкой физики

enum { INIT, ALIVE, INVULNERABLE, DEAD }  # перечисление состояний

@export var engine_power: int = 500  # мощность двигателя влияет на скорость
@export var spin_power: int = 8000  # мощность разворота

@export var bullet_scene: PackedScene  # сцена для создания экземпляров выстрелов
@export var fire_rate: float = 0.25  # время между выстрелами

var can_shoot = true  # флаг возможности стрелять

var thrust: Vector2 = Vector2.ZERO  # вектор движения - работы двигателя
var rotation_dir: float = 0  # направление вращения
var state = INIT  # начальное состояние

var screensize = Vector2.ZERO  # размер экрана

# ссылки на другие ноды
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var gun_cooldown = $GunCooldown
@onready var laser_sound = $LaserSound


func _ready():
	change_state(ALIVE)  # меняем стадию

	gun_cooldown.wait_time = fire_rate  # назначаем время между выстрелами
	screensize = get_viewport_rect().size  # получаем размер окна
	position = screensize / 2  # устанавливаем корабль в центре экрана


func change_state(new_state):
	# меняем состояние - тут в каждом состоянии регулируется отслеживание столкновений
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
	# в каждом цикле запускается функция управления
	get_input()


func get_input():
	thrust = Vector2.ZERO  # обнуляется направление движения
	if state in [DEAD, INIT]:  # если начальное или мертвое состяние ничего не происходит
		return

	if Input.is_action_pressed("thrust"):
		print(transform.origin)
		print(transform.x)
		print(transform.y)
		print("===================")
		thrust = transform.x * engine_power  # расчет силы двигателя по направлению х

	# вращение равно отрицательному или оложительному значению если left или right
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")

	# если пробел то запускаем функцию стрельбы
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
