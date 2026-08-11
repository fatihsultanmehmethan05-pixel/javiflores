# Control Manifest — Signal Array 04

> **Engine**: Godot Engine 4.7.1
> **Last Updated**: 2026-08-11
> **Manifest Version**: 2026-08-11
> **ADRs Covered**: ADR-001 (P2P Netcode), ADR-002 (3D Audio Routing), ADR-003 (JSON Persistence & Shop Economy)
> **Status**: Active

This Control Manifest is an actionable rules sheet for programmers working on **Signal Array 04**. It defines mandatory implementation patterns, forbidden anti-patterns, performance guardrails, and naming conventions across all architectural layers.

**Implementation note:** Required patterns include both enforced prototype rules and forward-looking roadmap constraints. Save persistence and spatial audio rules are not yet implemented; Steam uses an optional adapter only.

---

## Foundation Layer Rules

*Applies to: ENet network management, scene initialization, save/load persistence, main game state loop.*

### Required Patterns
- **Listen Server Netcode:** Host must create server using `ENetMultiplayerPeer.create_server(port, MAX_PLAYERS - 1)` on default port 7777 (Source: [ADR-001](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md)).
- **Authority Assignment:** Every network instance must call `set_multiplayer_authority(name.to_int())` in `_enter_tree()` (Source: [ADR-001](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md)).
- **Crash-Safe Persistence:** Save data must serialize atomically to `user://save_data.json` with fallback recovery backup to `user://save_data.bak` (Source: [ADR-003](file:///home/cem/Desktop/Nosignal/design/architecture/adr-003-json-save-serialization.md)).
- **State Machine Isolation:** Game state changes must transition exclusively through `MainGame.current_game_state` enum (`PLAYING`, `EXTRACTION_PHASE`, `DECODING_PHASE`, `GAME_OVER`, `VICTORY`).

### Forbidden Approaches
- **Never Run Client-Side State Calculations:** Antenna repair status, anomaly health, and shift payout must be evaluated under server authority (`multiplayer.is_server()`) (Source: [ADR-001](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md)).
- **Never Raw File Overwrite without Backup:** Save files must not be written without preserving previous backup copy.

### Performance Guardrails
- **Host CPU Load:** Host server frame update overhead must not exceed **2.0ms / frame**.

---

## Core Layer Rules

*Applies to: FPS player movement, flashlight power, 3D proximity radio static, interaction raycast.*

### Required Patterns
- **Grounded FPS Kinematics:** `Player` must extend `CharacterBody3D` with walk speed $3.5\text{ m/s}$, sprint $5.5\text{ m/s}$, and crouch $1.8\text{ m/s}$ (Source: [player-controller-fps.md](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md)).
- **Ceiling Clearance Check:** Crouching capsule height ($1.1\text{m}$) must not resize to standing ($1.8\text{m}$) if `CeilingRayCast.is_colliding()` is true.
- **RPC Flashlight Sync:** Only the owning player may emit `apply_flashlight_state(state)` for its flashlight; remote replicas never consume local input (Source: [flashlight-power-system.md](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md)).
- **Spatial Audio Attenuation (Planned):** Radio static and 3D sound effects must use `AudioStreamPlayer3D` with inverse distance attenuation (Source: [ADR-002](file:///home/cem/Desktop/Nosignal/design/architecture/adr-002-3d-spatial-audio.md)).

### Forbidden Approaches
- **Never Process Input for Remote Peers:** Physics and mouse input in `_physics_process` and `_unhandled_input` must check `is_multiplayer_authority()` first.
- **Never Ignore Battery Zero:** Flashlight light energy must instantly drop to 0 when `current_battery == 0.0`.

### Performance Guardrails
- **Player Controller Frame Budget:** Player physics process must execute under **0.5ms / frame**.

---

## Feature Layer Rules

*Applies to: Forest antenna panels, sector floodlights, CRT radar, anomaly AI, power switch.*

### Required Patterns
- **Procedural Shift Selection:** `ForestAntennaManager` must select exactly 3 damaged antennas out of candidate array on shift start (Source: [forest-antennae-system.md](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md)).
- **Standing Repair Rule:** Antenna panel repair requires `has_fuse == true` and standing posture (`current_state != CROUCHING`) for 1.5s hold time.
- **Safe Zone Disengagement:** `AnomalyThreat` AI must disengage chase and retreat to origin during `DECODING_PHASE` and `VICTORY` states (Source: [anomaly-entity-ai.md](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md)).
- **Remote Floodlight Cooldown:** Sector floodlight console buttons must enforce a 10s cooldown across all clients via RPC (Source: [tower-terminal-system.md](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md)).

### Forbidden Approaches
- **Never Attack Players During Terminal Decoding:** Anomalies must never deal damage when terminal decoding UI is active.
- **Never Allow Repair Without Fuse Kit:** Antenna panel must reject repair attempts if player `has_fuse` is false.

---

## Presentation Layer Rules

*Applies to: Diegetic HUD, Lobby UI, CRT screen displays, frequency decoder UI.*

### Required Patterns
- **CRT Phosphor Palette:** UI text must use CRT Phosphor Green (`#00FF66`), Warning Amber (`#FFB000`), or Crimson Red (`#D92B2B`) color overrides.
- **Mouse Mode Switching:** Opening modal UIs (`LobbyUI`, `SignalDecoder`) must set `Input.mouse_mode = MOUSE_MODE_VISIBLE`; closing must restore `MOUSE_MODE_CAPTURED`.
- **Dynamic Layout Containers:** UI layouts must use `MarginContainer`, `VBoxContainer`, and `HBoxContainer` with dynamic anchors.

### Forbidden Approaches
- **Never Use Plain White UI Defaults:** Avoid default unstyled browser/editor controls.
- **Never Hardcode Static Pixel Offsets:** Layout heights must derive dynamically from container bounds.

---

## Global Rules (All Layers)

### Naming Conventions
| Element | Convention | Example |
| :--- | :--- | :--- |
| **Classes** | `PascalCase` with `class_name` | `class_name TowerConsoleButton` |
| **Variables** | `snake_case` | `var current_battery: float` |
| **Signals** | `snake_case` (past tense) | `signal antenna_status_changed` |
| **Functions** | `snake_case` | `func activate_floodlight()` |
| **Constants** | `UPPER_SNAKE_CASE` | `const DEFAULT_PORT: int = 7777` |
| **Node Names** | `PascalCase` | `SpotLight3D`, `StatusLight` |

### Performance Budgets
| Metric | Budget Target |
| :--- | :--- |
| **Target Framerate** | 60 FPS |
| **Frame Time Budget** | 16.6 ms |
| **Draw Call Limit** | $\le 150$ draw calls |
| **Memory Ceiling** | $\le 512$ MB VRAM |

### Forbidden APIs (Godot 4.7.1)
- **Monolithic `TileMap` Node:** Use `TileMapLayer` nodes instead.
- **Legacy Signal Connection:** Do not use `connect("signal", self, "method")`; use `signal_name.connect(callable)` syntax.
- **`yield()` Keyword:** Use `await` for coroutine asynchronous flow.
- **Unannotated `export`:** Use `@export` for inspector properties.
