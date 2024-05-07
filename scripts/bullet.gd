extends Node3D

@export var speed: float = 20.0
const particles = preload("res://scenes/particles.tscn")

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

func _ready() -> void:
	$NoCollisionTimeout.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position -= transform.basis * Vector3(0,0,speed) * delta

func _on_area_entered(area):
	on_collision(area)
func _on_body_entered(body):
	on_collision(body)

func on_collision(collider):
	collision.disabled = true
	mesh.hide()
	collision.hide()
	
	var particle_instance = particles.instantiate()
	particle_instance.global_position = position
	get_parent().add_child(particle_instance)
	
	if collider.has_method("is_hit"):
		collider.is_hit()


func _on_no_collision_timeout_timeout():
	queue_free()
