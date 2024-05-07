extends CharacterBody3D


@export var speed: float = 10.0
@export var jump_velocity: float = 20.0
@export var gravity: float = 40.0

@onready var spring_arm_3d = $SpringArm3D
@onready var model = $Model
@onready var camera_trajectory = $SpringArm3D/Camera3D/CameraTrajectory
@onready var bullet_trajectory = $BulletTrajectory
@onready var camera = $SpringArm3D/Camera3D
@onready var crosshair = $SpringArm3D/Camera3D/Crosshair
@onready var weapon = $Model/gunstaff
@onready var bullet_spawn = $Model/gunstaff/BulletSpawn
@onready var aim = $AimCasts/Aim
@onready var fire = $AimCasts/Fire

var screen_center: Vector2
var bullet = preload("res://scenes/bullet.tscn")
var particle = preload("res://scenes/particles.tscn")
var RAY_LENGTH = 1000
var collision_point: Vector3

func _ready() -> void:
	camera.make_current()
	screen_center = get_viewport().get_visible_rect().size/2
	crosshair.position = screen_center
	
func _physics_process(delta: float) -> void:	
	check_aim()
	move(delta)
		
func _process(_delta: float) -> void:
	var turn_weight: float = 0.1
	model.rotation.y = lerp_angle(model.rotation.y, spring_arm_3d.rotation.y + deg_to_rad(180), turn_weight)
	spring_arm_3d.position = position
	weapon.rotation.z = -(camera.global_rotation.x - 45.4)
	weapon.rotation.y = deg_to_rad(90)
	
func shoot() -> void:
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = bullet_spawn.global_position
	bullet_instance.transform.basis = bullet_spawn.global_transform.basis
	#bullet_instance.bullet_collided.connect(_on_bullet_collision)
	get_parent().add_child(bullet_instance)
	
func check_aim() -> void:
		var origin = camera.project_ray_origin(screen_center)
		var end = origin + camera.project_ray_normal(screen_center) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin,end)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result:
			collision_point = result.position
		else:
			collision_point =  camera.project_ray_normal(screen_center) * RAY_LENGTH
		
		aim.global_position = origin
		aim.set_target_position(camera.project_ray_normal(screen_center) * RAY_LENGTH)
		
		fire.global_position = bullet_spawn.global_position
		fire.set_target_position(fire.to_local(collision_point))
		
		bullet_spawn.look_at(fire.to_global(fire.get_target_position()))
		
func move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	var input_dir = Input.get_vector("right", "left", "back", "forward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = direction.rotated(Vector3.UP, model.rotation.y).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()

#func _on_bullet_collision() -> void:
	#var particle_instance = particle.instantiate()
	#particle_instance.global_position = collision_point
	#get_parent().add_child(particle_instance)
