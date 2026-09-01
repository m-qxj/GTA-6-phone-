extends Control
# A simple on-screen analog stick. Works with real touch on
# Android, and with mouse drags in the editor (see
# `pointing/emulate_touch_from_mouse` in project.godot).

signal vector_changed(v: Vector2)

@export var radius := 70.0
var _touch_index := -1
var _center := Vector2.ZERO
var _knob: ColorRect

func _ready() -> void:
	custom_minimum_size = Vector2(radius, radius) * 2
	size = custom_minimum_size
	var bg := ColorRect.new()
	bg.color = Color(1, 1, 1, 0.15)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_knob = ColorRect.new()
	_knob.color = Color(1, 1, 1, 0.4)
	_knob.size = size * 0.35
	_knob.position = (size - _knob.size) * 0.5
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_knob)
	_center = size * 0.5

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_update_knob(_center)
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)

func _update_knob(local_pos: Vector2) -> void:
	var offset := local_pos - _center
	offset = offset.limit_length(radius)
	_knob.position = _center + offset - _knob.size * 0.5
	var v := offset / radius
	vector_changed.emit(Vector2(v.x, -v.y))  # invert y so "up" is positive
