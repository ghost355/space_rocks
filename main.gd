extends Node

@export var rock_scene: PackedScene

var screensize: Vector2 = Vector2.ZERO

@onready var rock_spawn = $RockPath/RockSpawn


func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	for i in 3:
		spawn_rock(3)


func spawn_rock(size: int, pos = null, vel = null) -> void:
	if pos == null:
		rock_spawn.progress = randi()
		pos = rock_spawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)

	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
