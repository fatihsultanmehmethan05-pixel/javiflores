# GDD: Player Controller FPS (`player-controller-fps`)

> **Status**: Implemented (Prototype)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`CharacterBody3D` + GDScript)
> **Implements Pillar**: Pillar 2 (Asymmetric Dependency) & Pillar 3 (Retro PSX Aesthetics)
> **Source Code**: [player.gd](file:///home/cem/Desktop/Nosignal/src/scripts/player.gd)

---

## 0. Current Implementation Note

The movement, crouch, interaction, local peer input ownership, and local-only camera selection are implemented in the playable prototype. Multiplayer movement remains client-owned and replicated; server-side movement validation and prediction are future hardening work.

## 1. Overview

**Player Controller FPS (`player-controller-fps`)** is the primary first-person movement, look, collision, crouch, sprint, inventory item holding, and diegetic interaction system in **Signal Array 04**. Built on Godot 4 `CharacterBody3D`, it provides grounded physics movement, camera pitch clamping, dynamic head bobbing, dynamic capsule resizing for crouch/ceiling clearance, fuse kit inventory tracking, and raycast interaction targeting.

---

## 2. Player Fantasy

The player experiences the vulnerable, physically grounded movement of a lone signal researcher navigating pitch-black volumetric forest terrain and narrow observatory stairwells. Actions feel heavy and deliberate—sprinting causes pronounced camera bobbing and noise, while crouching lowers capsule profile and flashlight beam height to avoid active anomaly detection.

---

## 3. Detailed Rules

### Movement & Kinematics
1. **Movement Speeds:**
   - Walking Speed (`walk_speed`): **3.5 m/s**
   - Sprinting Speed (`sprint_speed`): **5.5 m/s** (Forward movement only, holding Left Shift)
   - Crouching Speed (`crouch_speed`): **1.8 m/s**
2. **Capsule Dimensions & Crouch Physics:**
   - Standing State: Height = **1.8m**, Camera Y = **1.6m**, Radius = **0.4m**.
   - Crouching State: Height = **1.1m**, Camera Y = **0.9m**. Smooth linear interpolation at rate `10.0 * delta`.
   - Ceiling Detection: $1.0\text{m}$ upward `CeilingRayCast` prevents standing up when under low obstructions.
3. **Camera & Mouse Look:**
   - Sensitivity (`mouse_sensitivity`): **0.002 rad/px**.
   - Pitch Limits: Clamped strictly between **-85° and +85°**.
   - Mouse Mode: Toggled between `MOUSE_MODE_CAPTURED` and `MOUSE_MODE_VISIBLE` via `ui_cancel` (ESC) or left-click screen capture.
4. **Interaction System (`interact_distance = 3.5m`):**
   - Central `InteractRayCast` detects nodes extending `Interactable`.
   - Pressing and holding `E` fires `interact(player)` or `stop_repair()` upon release.
   - Holds boolean `has_fuse` for antenna panel repair verification.
5. **Health & Damage System:**
   - Maximum Health (`max_health`): **100.0 HP**.
   - Receives damage via `take_damage(amount)` emitting `health_changed` and `player_died`.

### States and Transitions

| Current State | Trigger / Input | Target State | Constraint / Rule |
| :--- | :--- | :--- | :--- |
| **IDLE** | W/A/S/D key pressed | **WALKING** | Grounded (`is_on_floor()`) |
| **WALKING** | Shift key held | **SPRINTING** | Forward vector active ($input\_dir.y < 0$) |
| **WALKING / IDLE** | Ctrl key pressed | **CROUCHING** | Capsule height reduces to 1.1m |
| **CROUCHING** | Ctrl key released | **WALKING / IDLE** | Allowed only if `CeilingRayCast` is clear |
| **ANY** | Health drops to 0 | **DEAD** | Input disabled, emits `player_died` signal |

---

## 4. Formulas

### 1. Velocity Interpolation & Friction
$$\mathbf{v}_{target} = (\mathbf{R} \cdot \mathbf{d}) \cdot speed$$
$$\mathbf{v}_{x,z} = \text{lerp}(\mathbf{v}_{x,z}, \mathbf{v}_{target, x,z}, accel \cdot \Delta t)$$
- **Acceleration ($accel$):** Ground = $10.0$, Air = $2.0$.
- **Friction ($friction$):** $12.0$.
- **Gravity ($gravity$):** $9.8 \text{ m/s}^2$.

### 2. Head Bobbing Offset
$$y_{bob} = \sin(t_{bob} \cdot f_{bob} \cdot 0.5) \cdot A_{bob}$$
- **Walking:** $f_{bob} = 10.0 \text{ Hz}$, $A_{bob} = 0.04 \text{ m}$.
- **Sprinting:** $f_{bob} = 14.0 \text{ Hz}$, $A_{bob} = 0.08 \text{ m}$.

---

## 5. Edge Cases

- **Ceiling Obstruction during Stand-Up:** If the player releases crouching while beneath a cabin desk or low beam, `ceiling_raycast.is_colliding()` forces the character to remain in `CROUCHING` state until cleared.
- **Steep Slope Movement:** Slopes exceeding $45^\circ$ (`floor_max_angle = deg_to_rad(45)`) trigger gravity sliding.
- **Input Freeze during Mini-Games:** Mouse input and movement are suspended when `Input.mouse_mode` is set to `MOUSE_MODE_VISIBLE` (e.g., during `LobbyUI` or `SignalDecoder`).

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`multiplayer-netcode-system`](file:///home/cem/Desktop/Nosignal/design/gdd/multiplayer-netcode-system.md): Receives peer authority (`set_multiplayer_authority(peer_id)`) and network transform replication.

### Downstream Dependents (Depends On This System)
- [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md): Mounts flashlight to `Head/Camera3D/Flashlight`.
- [`forest-antennae-system`](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md): Checks `player.has_fuse` and `player.current_state` during repairs.
- [`anomaly-entity-ai`](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md): Reads player global position, crouching state, and flashlight state for stealth detection.
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Displays interaction prompts, health, and battery levels.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `walk_speed` | 3.5 m/s | 2.0 – 5.0 | Normal walking velocity |
| `sprint_speed` | 5.5 m/s | 4.0 – 8.0 | Sprinting velocity |
| `crouch_speed` | 1.8 m/s | 1.0 – 3.0 | Crouching velocity |
| `accel` | 10.0 | 5.0 – 20.0 | Ground acceleration rate |
| `friction` | 12.0 | 5.0 – 25.0 | Ground deceleration rate |
| `mouse_sensitivity` | 0.002 | 0.0005 – 0.01 | Mouse look rotation scale |
| `interact_distance` | 3.5 m | 1.5 – 5.0 | Interaction raycast reach |

---

## 8. Acceptance Criteria

- **GIVEN** a player standing on terrain, **WHEN** W/A/S/D keys are pressed, **THEN** velocity accelerates smoothly to 3.5 m/s using ground acceleration.
- **GIVEN** a crouching player under a low roof, **WHEN** the crouch key is released, **THEN** the ceiling raycast holds capsule height at 1.1m until clear.
- **GIVEN** a player pointing camera within 3.5m of an interactable object, **WHEN** holding E key, **THEN** interaction signal `interact(player)` is continuously emitted.
