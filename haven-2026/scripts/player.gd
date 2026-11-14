extends CharacterBody3D


const SPEED_ORIGINAL = 5.0
var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var push_force = 10

@onready var Neck = $Neck
@onready var Dash = $DashTimer
@onready var DashMove = $DashMoveTimer
var is_dash_timedout = false

@onready var DashAudio = $Neck/Dash_sfx
@onready var JumpAudio = $Neck/Jump_sfx

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.01)
		Neck.rotate_x(-event.relative.y * 0.01)
		Neck.rotation.x = clampf(Neck.rotation.x, deg_to_rad(-90.0), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump."floor_block_on_wall"
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		JumpAudio.play()
	if Input.is_action_just_pressed("dash") and is_dash_timedout == false:
		print("dash")
		Dash.start()
		DashAudio.play()
		is_dash_timedout = true
		SPEED += 20
		DashMove.start()
		print("dash applied")
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left_strafe", "right_strafe", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# deal with moving rigidbodies
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	is_dash_timedout = false
	print("dash timeout over")
	Dash.stop()


func _on_dash_move_timer_timeout() -> void:
	SPEED = SPEED_ORIGINAL
	print("boost removed")
