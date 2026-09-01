extends CanvasLayer
# Mobile touch HUD: two virtual sticks + a handful of buttons,
# all wired directly into GameManager's shared input state.

const VirtualJoystick := preload("res://scripts/ui/virtual_joystick.gd")

func _ready() -> void:
	layer = 10
	var vp := get_viewport().get_visible_rect().size

	var move_stick := VirtualJoystick.new()
	move_stick.position = Vector2(50, vp.y - 210)
	move_stick.vector_changed.connect(func(v): GameManager.move_vector = v)
	add_child(move_stick)

	var look_stick := VirtualJoystick.new()
	look_stick.position = Vector2(vp.x - 190, vp.y - 210)
	look_stick.vector_changed.connect(func(v): GameManager.look_vector = v)
	add_child(look_stick)

	_add_button("Jump", Vector2(vp.x - 340, vp.y - 260), func(): GameManager.jump_pressed = true)
	_add_button("Enter/Exit", Vector2(vp.x - 340, vp.y - 190), func(): GameManager.request_enter_exit())

	var handbrake := Button.new()
	handbrake.text = "Brake"
	handbrake.custom_minimum_size = Vector2(110, 48)
	handbrake.position = Vector2(vp.x - 340, vp.y - 120)
	handbrake.button_down.connect(func(): GameManager.handbrake_held = true)
	handbrake.button_up.connect(func(): GameManager.handbrake_held = false)
	add_child(handbrake)

	_add_button("30 FPS", Vector2(20, 16), func(): SettingsManager.set_fps(30))
	_add_button("60 FPS", Vector2(150, 16), func(): SettingsManager.set_fps(60))

func _add_button(text: String, pos: Vector2, callback: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(110, 48)
	b.position = pos
	b.pressed.connect(callback)
	add_child(b)
