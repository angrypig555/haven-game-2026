extends CharacterBody3D



const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var Neck = $Neck
@onready var Dash = $DashTimer
var is_dash_timedout = false

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
	if Input.is_action_just_pressed("dash") and is_dash_timedout == false:
		print("dash")
		Dash.start()
		is_dash_timedout = true
		
		
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

	move_and_slide()


func _on_dash_timer_timeout() -> void:
	is_dash_timedout = false
	print("dash timeout over")
	Dash.stop()
