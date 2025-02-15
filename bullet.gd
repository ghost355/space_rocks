extends Area2D

@export var speed: int = 1000

var velocity: Vector2 = Vector2.ZERO


func start(_transform):
	transform = _transform
	velocity = transform.x * speed


func _process(delta: float):
	position += velocity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
