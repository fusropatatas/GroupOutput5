extends Node3D

@onready var particles = $GPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready():
	particles.emitting = true
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
