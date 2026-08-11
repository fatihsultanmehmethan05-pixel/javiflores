# Technical Preferences

## Engine & Language
- **Engine**: Godot 4.7
- **Primary Language**: GDScript
- **Engine Binary Path**: `/home/cem/Apps/Godot`

## Naming Conventions
- **Classes**: PascalCase (e.g., `PlayerController`)
- **Variables / Functions**: snake_case (e.g., `move_speed`, `take_damage()`)
- **Signals**: snake_case past tense (e.g., `health_changed`, `signal_received`)
- **Script Files**: snake_case matching class concept (e.g., `player_controller.gd`)
- **Scene Files**: PascalCase matching root node (e.g., `PlayerController.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `SIGNAL_FREQUENCY`)

## Input & Platform
- **Target Platforms**: PC (Steam)
- **Input Methods**: Keyboard/Mouse, Gamepad
- **Primary Input**: Keyboard/Mouse
- **Gamepad Support**: Full (d-pad navigation for UI)
- **Touch Support**: None
- **Platform Notes**: Steam PC launch first. UI must support both mouse pointing and gamepad focus navigation.

## Performance Budgets
- **Target Framerate**: 60 FPS
- **Frame Time Budget**: 16.6 ms
- **Max Active Draw Calls**: 500
- **VRAM Budget**: < 2 GB (PSX Low-Poly textures & mesh budget)

## Testing Framework
- **Test Runner**: GUT (Godot Unit Testing framework for GDScript)

## Engine Specialists
- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all `.gd` files)
- **Shader Specialist**: godot-shader-specialist (`.gdshader` files, VisualShader resources)
- **UI Specialist**: godot-specialist (Control nodes, UI themes, focus navigation)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|---|---|
| Game code (`.gd` files) | `godot-gdscript-specialist` |
| Shader / material files (`.gdshader`, `VisualShader`) | `godot-shader-specialist` |
| UI / screen files (`Control` nodes, `CanvasLayer`) | `godot-specialist` |
| Scene / prefab / level files (`.tscn`, `.tres`) | `godot-specialist` |
| Native extension / plugin files (`.gdextension`, C++) | `godot-gdextension-specialist` |
| General architecture review | `godot-specialist` |
