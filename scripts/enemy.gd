extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const particles = preload("res://scenes/explosion.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var MAX_HEALTH: int
var health: int
@onready var model = $Model
var choice: int
func _ready() -> void:
	health = MAX_HEALTH
	$MoveTimer.start()
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	match choice:
		0:
			rotation.y = lerp_angle(rotation.y, rotation.y + deg_to_rad(90), 0.09)
		1:
			rotation.y = lerp_angle(rotation.y, rotation.y + deg_to_rad(-90), 0.09)
		2:
			position = lerp(position, position + transform.basis * Vector3(0.5,0,0), 0.1)
		_:
			pass
	

	move_and_slide()
	
func is_hit() -> void:
	health -= 1
	if health <= 0:
		enemy_death()
		
func enemy_death():
	$DeathAnimTimer.start()
	model.hide()
	$CollisionShape3D.disabled = true
	
	var particle_instance = particles.instantiate()
	particle_instance.global_position = position
	get_parent().add_child(particle_instance)
		
	queue_free()

func _on_move_timer_timeout():
	choice = randi_range(0,2)
