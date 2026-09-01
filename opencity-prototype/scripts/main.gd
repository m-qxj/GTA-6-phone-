extends Node3D
# ============================================================
# Open City Prototype — main world builder.
# Builds an open-world block grid (roads + buildings), lighting,
# spawns the player and a few drivable cars, and sets up mobile
# touch controls. Everything here is placeholder geometry —
# swap in real 3D models/textures later for a much better look.
# ============================================================

const BLOCK_SIZE := 40.0
const GRID_SIZE := 8       # 8x8 blocks
const ROAD_WIDTH := 10.0

var player_scene := preload("res://scenes/player.tscn")
var car_scene := preload("res://scenes/car.tscn")

func _ready() -> void:
	_setup_environment()
	_build_city()
	_spawn_player()
	_spawn_cars()
	_setup_ui()
	SettingsManager.apply_saved_fps()

func _setup_environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.55, 0.95)
	sky_mat.sky_horizon_color = Color(0.75, 0.85, 0.95)
	sky_mat.ground_bottom_color = Color(0.2, 0.2, 0.25)
	sky_mat.ground_horizon_color = Color(0.6, 0.6, 0.65)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)
	# Slow cosmetic day/night rotation. Tune the duration or remove freely.
	var tween := create_tween().set_loops()
	tween.tween_property(sun, "rotation_degrees:x", 190, 300.0).from(-55)

func _build_city() -> void:
	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(GRID_SIZE * BLOCK_SIZE, GRID_SIZE * BLOCK_SIZE)
	ground.mesh = ground_mesh
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.15, 0.15, 0.16)
	ground.material_override = road_mat
	var ground_body := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(GRID_SIZE * BLOCK_SIZE, 0.1, GRID_SIZE * BLOCK_SIZE)
	ground_shape.shape = shape
	ground_body.add_child(ground_shape)
	ground.add_child(ground_body)
	add_child(ground)

	var half := GRID_SIZE * BLOCK_SIZE * 0.5
	for gx in range(GRID_SIZE):
		for gz in range(GRID_SIZE):
			# Leave every 3rd row/col open as road/plaza space.
			if gx % 3 == 0 or gz % 3 == 0:
				continue
			var cx := -half + gx * BLOCK_SIZE + BLOCK_SIZE * 0.5
			var cz := -half + gz * BLOCK_SIZE + BLOCK_SIZE * 0.5
			_add_building(Vector3(cx, 0, cz))

func _add_building(pos: Vector3) -> void:
	var height := randf_range(6.0, 40.0)
	var footprint := BLOCK_SIZE - ROAD_WIDTH
	var body := StaticBody3D.new()
	body.position = pos + Vector3(0, height * 0.5, 0)
	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(footprint, height, footprint)
	mesh_inst.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(randf_range(0.4, 0.9), randf_range(0.4, 0.9), randf_range(0.4, 0.9))
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)
	var col := CollisionShape3D.new()
	var col_shape := BoxShape3D.new()
	col_shape.size = box.size
	col.shape = col_shape
	body.add_child(col)
	add_child(body)

func _spawn_player() -> void:
	var player := player_scene.instantiate()
	player.position = Vector3(0, 2, 0)
	add_child(player)
	GameManager.player = player

func _spawn_cars() -> void:
	var spawn_points := [Vector3(15, 1, 5), Vector3(-25, 1, 30), Vector3(50, 1, -10)]
	for p in spawn_points:
		var car := car_scene.instantiate()
		car.position = p
		add_child(car)

func _setup_ui() -> void:
	var ui := preload("res://scenes/ui/touch_controls.tscn").instantiate()
	add_child(ui)
