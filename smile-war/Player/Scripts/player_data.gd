extends Node

@onready var character := $".."
@onready var model := $"../smiley/Sphere"
@onready var player_cam := $"../PayerCam"
@onready var rail_ray: RayCast3D = $"../CollisionShape3D/RailAnchor/RailRay"
@onready var particles: GPUParticles3D = $"../RailgunParticles"

@export var id : int = 1
@export var host_color : Color = Color8(255, 222, 0, 255)
@export var client_color : Color = Color8(255, 222, 0, 255)
var color = Color(255, 255, 0)
@export var is_local_player := false


func try_fire(ray_dir):
	if fire_timer <= 0:
		shoot(ray_dir, rail_ray.global_position)
		fire_timer = 55

@rpc("any_peer", "reliable", "call_local")
func shoot(ray_dir: Vector3, pos: Vector3):
	print("FIRE! shooter: ", $"..".name, " is server: ", multiplayer.is_server())
	rail_ray.global_basis.z = ray_dir
	var col = rail_ray.get_collider()
	var point = rail_ray.get_collision_point()
	var mid = pos + ray_dir * (45.0/2.0)
	particles.process_material.emission_box_extents.y = 45
	particles.amount = 522
	print("col: ", col)
	if col:
		var dist = pos.distance_to(point)
		mid = lerp(pos, point, 0.5)
		particles.process_material.emission_box_extents.y = dist / 2
		particles.amount = clamp(roundf(dist) * 12, 1, 9999)
		
		if col.collision_layer == 2:
			print("Hit player: ", col.name.to_int())
			get_tree().root.get_child(0).report_hit.rpc(col.name.to_int())
		
	particles.global_position = mid
	print("mid pos: ", mid)
	particles.draw_pass_1.surface_get_material(0).albedo_color = color
	particles.global_basis.y = ray_dir
	relay_shoot.rpc(particles.global_position, ray_dir, particles.process_material.emission_box_extents.y)
	particles.emitting = true

@rpc("any_peer", "reliable", "call_remote")
func relay_shoot(pos, ray_dir, len):
	print("recieved fire relay pos: ", pos, " dir: ", ray_dir, " len: ", len)
	particles.global_position = pos
	particles.global_basis.y = ray_dir
	particles.amount = roundf(len) * 24
	particles.process_material.emission_box_extents.y = len 
	particles.emitting = true
	

@rpc("authority", "reliable", "call_remote")
func send_info(t_color: Color):
	color = t_color

func set_up(t_id: int, t_color: Color):
	id = t_id
	is_local_player = id == multiplayer.get_unique_id()
	var t_mat = model.get_surface_override_material(0)
	t_mat.albedo_color = t_color
	color = t_color
	print("color: ", color, " is server: ", multiplayer.is_server())
	

# Called when the node enters the scene tree for the first time.

	
var fire_timer := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if fire_timer > 0: fire_timer -= 1
