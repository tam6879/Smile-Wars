extends CharacterBody3D


const SPEED = 5.0
const TURN_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const GRAVITY = -5
const MOUSE_SENS_X = 0.3
const MOUSE_SENS_Y = -0.3
@onready var player_data = $PlayerData
@onready var cam: Camera3D = $PayerCam
@onready var ground_sniffer: Area3D = $Area3D
@export var player_id : int
@export var score: int = 0

var is_local_player := false

#func _enter_tree() -> void:
	#set_multiplayer_authority(str(name).to_int())
	#print("entered tree")

func _ready() -> void:
	if not is_multiplayer_authority():
		cam.clear_current()

@rpc("authority", "call_local", "reliable")
func set_up_player(id: int, t_color: Color) -> void:
	print("setting up player id: ", id, " is server: ", multiplayer.is_server())
	# set ID
	player_id = id
	is_local_player = id == multiplayer.get_unique_id()
	player_data.set_up(id, t_color)
	set_multiplayer_authority(id)
	
	if is_local_player:
		cam.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("set current cam client")

		

@rpc("authority", "call_remote", "reliable")
func recieve_spawn(pos: Vector3):
	print("recieved spawn on client")
	global_position = pos

var camera_angle = 0
func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority() or not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	if event is InputEventMouseMotion:
		$".".rotate_y(deg_to_rad(-event.relative.x*MOUSE_SENS_X))
		var t_change=-event.relative.y*MOUSE_SENS_Y
		if camera_angle + t_change > -80 and camera_angle + t_change < 80:
			camera_angle += t_change
			cam.rotate_x(deg_to_rad(t_change))
			$CollisionShape3D/RailAnchor.rotate_x(deg_to_rad(t_change))
			$smiley.rotate_x(deg_to_rad(t_change))
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var grounded := false
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	# Add the gravity.
	# if not is_local_player: return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_axis = Input.get_vector("Right", "Left", "Backward", "Forward")
	var turn_axis = Input.get_axis("Turn Right", "Turn Left")
	if turn_axis: rotate_y(turn_axis * TURN_SPEED * delta)
	if move_axis:
		# velocity.x = direction.x * SPEED
		var t_y = velocity.y
		velocity = global_basis.z * move_axis.y * SPEED + global_basis.x * move_axis.x * SPEED
		velocity.y = t_y
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Handle jump.
	grounded = len(ground_sniffer.get_overlapping_bodies() + ground_sniffer.get_overlapping_areas()) != 0
	
	if Input.is_action_pressed("Jump") and grounded:
		velocity.y = JUMP_VELOCITY
	elif not grounded:
		velocity.y += GRAVITY * delta
	if Input.is_action_pressed("Fire"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player_data.try_fire(-cam.global_basis.z)
	if Input.is_action_just_pressed("Quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	move_and_slide()
	send_pos.rpc(global_position, global_rotation, $smiley.rotation)

@rpc("any_peer", "call_remote")
func send_pos(pos, rot, body_rot):
	global_position = pos
	global_rotation = rot
	$smiley.rotation = body_rot
	
