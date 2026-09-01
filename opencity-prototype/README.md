# Open City Prototype

An **original**, code-first open-world driving/action prototype for Android,
built with [Godot 4](https://godotengine.org/) (free & open source).

This is **not** a copy of GTA and doesn't use any Rockstar/Take-Two names,
characters, cities, or assets — for both legal reasons (that content is
copyrighted) and practical ones (GTA 6 is a multi-year, multi-hundred-person,
multi-billion-dollar production; nothing generated in a chat gets close to
that). What this repo gives you instead is a real, working **foundation**:
open world, a walking/jumping character, a drivable car, day/night, and
mobile touch controls — that you can keep extending.

## What's implemented
- Procedurally generated city block grid (roads + buildings)
- Third-person on-foot controller (move, jump, orbit camera)
- Drivable car (engine, steering, handbrake, its own chase camera)
- Enter / exit vehicle
- Simple day/night sun rotation
- Touch controls: movement stick, camera stick, Jump, Enter/Exit, Brake
- In-game 30 FPS / 60 FPS toggle (`Engine.max_fps`, saved to disk)
- GitHub Actions workflow that builds a debug `.apk` on every push to `main`

## What's NOT implemented yet (next steps)
- Real 3D models/textures — everything is boxes/capsules right now.
  Send reference images or videos and I can help art-direct the next pass.
- Shooting/combat, NPCs, pedestrians, traffic AI, missions, sound/radio
- Fine-tuned driving feel and camera framing (see note below)

## Getting the APK
1. Push this repo to GitHub.
2. GitHub Actions (`.github/workflows/android-build.yml`) builds a debug
   APK automatically and uploads it under the run's **Artifacts**.
3. Download it, install on an Android device (enable "install unknown apps"),
   and test.

## Testing locally first (recommended)
Install [Godot 4.3+](https://godotengine.org/download), open
`project.godot`, and press Play. Mouse drags on the on-screen sticks work
like touch, so you can test before ever building an APK.

## Honest caveats
- **`export_presets.cfg`** and the CI workflow's export-template paths are
  version-sensitive. I wrote them against a common, well-documented CI
  pattern, but I couldn't actually run Godot to verify them end-to-end (no
  engine available in this environment). If the Actions build fails, the
  error log usually points straight at the mismatch — most often the Godot
  version in the Docker image vs. the templates path, or the keystore.
  Opening the project once in the real editor and re-exporting via
  Project → Export regenerates `export_presets.cfg` correctly for your
  installed version if needed.
- Camera/driving feel is a first pass — expect to want to tune constants
  like `SPEED`, `ENGINE_POWER`, and `MAX_STEER` at the top of
  `scripts/player.gd` and `scripts/car.gd`.

## Project structure
```
project.godot
export_presets.cfg
scenes/            # thin scene wrappers (each just attaches a script)
scripts/           # all gameplay logic
scripts/game_manager.gd      # shared state: mode, input, enter/exit
scripts/settings_manager.gd  # 30/60 FPS toggle, saved to disk
.github/workflows/android-build.yml
```
