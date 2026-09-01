extends Node
# Autoload singleton. Holds shared game state so the player,
# the car, and the touch UI can all talk to each other without
# needing direct node references wired up in the editor.

enum Mode { ON_FOOT, DRIVING }

var mode: Mode = Mode.ON_FOOT
var player: Node3D
var current_vehicle: Node3D

# Shared input coming from the on-screen touch controls.
# Thanks to `pointing/emulate_touch_from_mouse` in project.godot,
# these also work with mouse drags when testing inside the editor.
var move_vector: Vector2 = Vector2.ZERO   # left stick: move / steer
var look_vector: Vector2 = Vector2.ZERO   # right stick: camera look
var jump_pressed: bool = false
var handbrake_held: bool = false

func request_enter_exit() -> void:
	if mode == Mode.ON_FOOT:
		var nearby := _find_nearby_vehicle()
		if nearby:
			current_vehicle = nearby
			mode = Mode.DRIVING
			player.visible = false
			player.set_physics_process(false)
			current_vehicle.driver_enter()
	else:
		if current_vehicle:
			player.global_position = current_vehicle.global_position + Vector3(2, 0.5, 0)
			player.visible = true
			player.set_physics_process(true)
			current_vehicle.driver_exit()
			player.camera.current = true
		mode = Mode.ON_FOOT
		current_vehicle = null

func _find_nearby_vehicle() -> Node3D:
	var best: Node3D = null
	var best_dist := 4.0  # must be within 4m to get in
	for c in get_tree().get_nodes_in_group("cars"):
		var d: float = player.global_position.distance_to(c.global_position)
		if d < best_dist:
			best_dist = d
			best = c
	return best
