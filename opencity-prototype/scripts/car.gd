extends VehicleBody3D
# Drivable car: builds its own body/wheel/camera rig at runtime.
# Front (steering) wheels face -Z, which is Godot's forward
# convention — if it drives backwards for you, flip ENGINE_POWER's
# sign or swap the front/rear wheel Z positions below.

const ENGINE_POWER := 180.0
const MAX_STEER := 0.6
const BRAKE_POWER := 4.0

var camera: Camera3D
var spring_arm: SpringArm3D
var _driver_inside := false

func _ready() -> void:
	add_to_group("cars")
	mass = 900.0

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.8, 1.0, 4.0)
	mesh_inst.mesh = box
	mesh_inst.position.y = 0.5
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.1, 1.0))
	mat.metallic = 0.6
	mat.roughness = 0.3
	mesh_inst.material_override = mat
	add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 1.0, 4.0)
	col.shape = shape
	col.position.y = 0.5
	add_child(col)

	_add_wheel(Vector3(-0.8, 0.0, -1.4), true)   # front-left (steers)
	_add_wheel(Vector3(0.8, 0.0, -1.4), true)    # front-right (steers)
	_add_wheel(Vector3(-0.8, 0.0, 1.4), false)   # rear-left
	_add_wheel(Vector3(0.8, 0.0, 1.4), false)    # rear-right

	spring_arm = SpringArm3D.new()
	spring_arm.position = Vector3(0, 2.0, 0)
	spring_arm.rotation_degrees = Vector3(-12, 180, 0)  # fixed chase cam, behind the car
	spring_arm.spring_length = 7.0
	add_child(spring_arm)

	camera = Camera3D.new()
	camera.rotation_degrees.y = 180
	spring_arm.add_child(camera)

func _add_wheel(pos: Vector3, steers: bool) -> void:
	var wheel := VehicleWheel3D.new()
	wheel.position = pos
	wheel.use_as_steering = steers
	wheel.use_as_traction = true
	wheel.wheel_radius = 0.4
	wheel.wheel_rest_length = 0.15
	wheel.suspension_stiffness = 40.0
	add_child(wheel)

func driver_enter() -> void:
	_driver_inside = true
	camera.current = true

func driver_exit() -> void:
	_driver_inside = false
	camera.current = false

func _physics_process(_delta: float) -> void:
	if not _driver_inside:
		engine_force = 0
		brake = 0
		return

	var input := GameManager.move_vector
	engine_force = input.y * ENGINE_POWER
	steering = -input.x * MAX_STEER
	brake = BRAKE_POWER if GameManager.handbrake_held else 0.0
