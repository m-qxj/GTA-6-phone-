extends Node
# Autoload singleton. Handles the 30/60 FPS toggle requested in
# the brief, persisted to disk so it survives app restarts.

const SAVE_PATH := "user://settings.cfg"

var target_fps: int = 60

func apply_saved_fps() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		target_fps = cfg.get_value("graphics", "fps", 60)
	Engine.max_fps = target_fps

func set_fps(fps: int) -> void:
	target_fps = fps
	Engine.max_fps = fps
	var cfg := ConfigFile.new()
	cfg.set_value("graphics", "fps", fps)
	cfg.save(SAVE_PATH)
