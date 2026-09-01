extends CharacterBody3D
# On-foot controller: reads shared input from GameManager
# (fed by the touch joysticks), moves relative to the camera,
# and rebuilds its own visuals/camera rig at runtime so no
# hand-authored scene tree is needed.

const SPEED := 6.0
const JUMP_VELOCITY := 6.5
const GRAVITY := 18.0
const ROTATE_SPEED := 6.0

var camera: Camera3D
var spring_arm: SpringArm3D
var camera_yaw := 180.0   # 180 baseline = camera starts behind the character
var camera_pitch := -20.0

func _ready() -> void:
	add_to_group("player")

	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var cap_mesh := CapsuleMesh.new()
	cap_mesh.radius = 0.4
	cap_mesh.height = 1.8
	mesh_inst.mesh = cap_mesh
	mesh_inst.position.y = 0.9
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.3, 0.2)
	mesh_inst.material_override = mat
	add_child(mesh_inst)

	spring_arm = SpringArm3D.new()
	spring_arm.position = Vector3(0, 1.6, 0)
	spring_arm.spring_length = 6.0
	add_child(spring_arm)

	camera = Camera3D.new()
	camera.current = true
	camera.rotation_degrees.y = 180  # look back at the pivot, not further away
	spring_arm.add_child(camera)

func _physics_process(delta: float) -> void:
	if GameManager.mode != GameManager.Mode.ON_FOOT:
		return

	camera_yaw -= GameManager.look_vector.x * delta * 120.0
	camera_pitch = clamp(camera_pitch - GameManager.look_vector.y * delta * 80.0, -60.0, 10.0)
	spring_arm.rotation_degrees = Vector3(camera_pitch, camera_yaw, 0)

	# Move relative to where the camera is actually looking, so "stick up"
	# always means "go where I'm looking" regardless of orbit angle.
	var cam_basis := camera.global_transform.basis
	var input := GameManager.move_vector
	var direction := (cam_basis.x * input.x - cam_basis.z * input.y)
	direction.y = 0
	direction = direction.normalized() if direction.length() > 0.01 else Vector3.ZERO

	if direction != Vector3.ZERO:
		var target_angle := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, ROTATE_SPEED * delta)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * 4 * delta)

	if is_on_floor():
		if GameManager.jump_pressed:
			velocity.y = JUMP_VELOCITY
			GameManager.jump_pressed = false
	else:
		velocity.y -= GRAVITY * delta

	move_and_slide()
