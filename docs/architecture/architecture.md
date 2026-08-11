# Signal Array 04 — Master Architecture Document

> **Version:** 1.0
> **Last Updated:** 2026-08-11
> **Engine:** Godot Engine 4.7.1 (`Forward+` Renderer, GDScript)
> **Architecture Pattern:** Host-as-Server Peer-to-Peer Listen Server ([ADR-001](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md))
> **Technical Director Sign-Off:** APPROVED AS DESIGN BLUEPRINT
> **Implementation Alignment:** PARTIAL — playable prototype exists; save/progression, spatial audio/voice, authoritative decoder/team outcome, and Steam lobby/relay remain pending

---

## 1. Document Overview & Context

**Current implementation note:** This document describes the target architecture. “Covered” means an architectural module or planned owner is identified; it does not by itself mean the behavior is implemented or acceptance-tested. Current behavioral status is tracked in `design/gdd/systems-index.md` and `docs/architecture/requirements-traceability.md`.

This Master Architecture Document translates all 9 approved Game Design Documents (GDDs) into a unified, modular technical blueprint for **Signal Array 04**. It defines the system layer stack, module ownership boundaries, data flow paths, API contracts, ADR audit, and requirements traceability matrix.

---

## 2. Technical Requirements Baseline (TR-Index)

| Requirement ID | Source GDD | System | Domain | Technical Constraint / Rule |
| :--- | :--- | :--- | :--- | :--- |
| `TR-player-001` | `player-controller-fps` | Player | Core | Grounded 3D FPS kinematics (3.5m/s walk, 5.5m/s sprint, 1.8m/s crouch) via `CharacterBody3D`. |
| `TR-player-002` | `player-controller-fps` | Player | Core | Dynamic capsule height (1.8m $\to$ 1.1m) with `CeilingRayCast` obstruction detection. |
| `TR-player-003` | `player-controller-fps` | Player | Core | Central 3.5m `InteractRayCast` targeting `Interactable` nodes and holding `has_fuse` state. |
| `TR-netcode-001` | `multiplayer-netcode-system` | Netcode | Foundation | Host-as-Server P2P Listen Server on port 7777 using `ENetMultiplayerPeer` (ADR-001). |
| `TR-netcode-002` | `multiplayer-netcode-system` | Netcode | Foundation | Dynamic peer spawning at tower foot with stringified `peer_id` authority (`set_multiplayer_authority`). |
| `TR-netcode-003` | `multiplayer-netcode-system` | Netcode | Foundation | Reliable RPC synchronization for flashlight state, console buttons, and sector floodlights. |
| `TR-flashlight-001` | `flashlight-power-system` | Flashlight | Core | Continuous battery depletion (0.8 u/s, 125s burn time) and low-battery flickering ($\le 20\%$). |
| `TR-flashlight-002` | `flashlight-power-system` | Flashlight | Core | Active flashlight beam overriding crouch stealth for anomaly detection. |
| `TR-antennae-001` | `forest-antennae-system` | Antennae | Feature | Procedural shift initializer selecting 3 damaged antennas out of 8 candidate panels. |
| `TR-antennae-002` | `forest-antennae-system` | Antennae | Feature | Electrical Fuse Kit requirement (`FusePickup.tscn`) and 1.5s standing hold-E panel repair. |
| `TR-terminal-001` | `tower-terminal-system` | Terminal | Feature | 3D CRT Radar monitor displaying live cardinal direction blips (NORTH-EAST, WEST, etc.). |
| `TR-terminal-002` | `tower-terminal-system` | Terminal | Feature | Remote 4-button sector floodlight console (12s active, 10s cooldown) illuminating 45m sectors. |
| `TR-terminal-003` | `tower-terminal-system` | Terminal | Feature | Main power switch lockdown unlocking extraction and frequency decoder mini-game. |
| `TR-terminal-004` | `tower-terminal-system` | Terminal | Feature | Frequency wavelength decoder UI (`A`/`D` keys) matching target frequency within $\pm 15$ Hz tolerance. |
| `TR-anomaly-001` | `anomaly-entity-ai` | Anomaly AI | Feature | Area3D patrol/chase state machine (2.4 m/s chase, 9m detection, 12 HP/s contact damage). |
| `TR-anomaly-002` | `anomaly-entity-ai` | Anomaly AI | Feature | Stealth detection sensor (`crouching == true` and `flashlight_on == false`). |
| `TR-anomaly-003` | `anomaly-entity-ai` | Anomaly AI | Feature | Safe zone disengagement during `DECODING_PHASE` and `VICTORY` states. |
| `TR-ui-001` | `diegetic-ui-system` | Presentation | Presentation | Diegetic HUD displaying prompts, health, battery, stealth label, and radio static warning. |
| `TR-ui-002` | `diegetic-ui-system` | Presentation | Presentation | Multiplayer Lobby UI overlay (`CanvasLayer` layer 10) with mouse mode capture toggles. |
| `TR-radio-001` | `radio-communication-system` | Radio Audio | Core | Distance-based radio static warning ($<12$m threat) and signal frequency beeping ($<15$m antenna). |
| `TR-save-001` | `save-progression-system` | Meta Save | Foundation | Multi-night shift progression (Day 1 $\to$ Day 3) with credit rewards ($150 base + $100/cassette). |
| `TR-save-002` | `save-progression-system` | Meta Save | Foundation | Tower Supply Shop for high-capacity batteries ($75), motion sensors ($120), and flare guns ($180). |
| `TR-save-003` | `save-progression-system` | Meta Save | Foundation | JSON save data serialization to `user://save_data.json`. |

---

## 3. System Layer Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                         │
│  - Diegetic UI / HUD (hud.gd)          - Lobby UI Overlay (lobby_ui.gd)     │
│  - Signal Decoder UI (signal_decoder.gd)- 3D CRT Radar Label (tower_radar.gd)│
├─────────────────────────────────────────────────────────────────────────────┤
│  FEATURE LAYER                                                              │
│  - Forest Antenna Manager              - Remote Sector Floodlight Poles     │
│  - Antenna Repair Panels & Fuse Pickups - Tower Console 4-Button Controls    │
│  - Anomaly Threat Stalking AI          - Main Observatory Power Switch      │
├─────────────────────────────────────────────────────────────────────────────┤
│  CORE LAYER                                                                 │
│  - Player Character Controller (FPS)   - Flashlight Power & Flicker Manager │
│  - 3D Proximity Radio Static Engine    - Interaction Raycast & Fuse Inv.   │
├─────────────────────────────────────────────────────────────────────────────┤
│  FOUNDATION LAYER                                                           │
│  - ENet Network Manager (ADR-001)      - Main Game State Machine (Loop)     │
│  - Peer Authority Spawner              - Save/Load System (JSON Persistence)│
├─────────────────────────────────────────────────────────────────────────────┤
│  PLATFORM LAYER                                                             │
│  - Godot Engine 4.7.1 Executable       - Linux / Windows OS Shell           │
│  - ENet Socket Networking              - OpenGL / Forward+ Vulkan Renderer  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Module Ownership Map

| Module Name | Layer | Owns (Exclusive Data) | Exposes (Public Interface) | Consumes (Inputs) | Engine APIs Used |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `NetworkManager` | Foundation | Peer connections, host/client state | `create_host()`, `join_game()`, signals | Port 7777, ENet events | `ENetMultiplayerPeer`, `multiplayer` |
| `MainGame` | Foundation | Shift state (`GameState`), active phase | `current_game_state`, signals | Antenna & decoder signals | `Node3D`, `SceneTree` |
| `Player` | Core | Health (100 HP), velocity, `has_fuse` | `take_damage()`, signals | Keyboard/Mouse inputs | `CharacterBody3D`, `RayCast3D` |
| `Flashlight` | Core | Battery level (100 u), `is_on` | `toggle()`, `apply_flashlight_state()` | Process delta, owner-authority RPC | `SpotLight3D`, `@rpc` |
| `ForestAntennaManager` | Feature | Damaged antenna node pool | `active_damaged_antennae`, signals | Panel status signals | `Node3D` |
| `AntennaPanel` | Feature | Repair progress (0-1.5s), fixed state | `interact()`, `stop_repair()`, signals | Player hold-E, `has_fuse` | `Interactable`, `OmniLight3D` |
| `AnomalyThreat` | Feature | State (Patrol/Chase), position | Patrol targets, damage dealing | Player position & stealth | `Area3D`, `OmniLight3D` |
| `TowerConsoleButton` | Feature | Cooldown timer (10s), sector name | `interact()`, `request_trigger()` | E key press, host-validated RPC | `Interactable`, `@rpc` |
| `SectorFloodlight` | Feature | Active duration timer (12s), lights | `activate_floodlight()`, RPCs | Console trigger signals | `SpotLight3D`, `OmniLight3D` |
| `SignalDecoder` | Presentation | Wavelength match progress (0-100%) | `open_decoder()`, `close_decoder()` | A/D frequency inputs | `CanvasLayer`, `ProgressBar` |
| `HUD` | Presentation | Screen labels & progress bars | `update_health()`, `set_prompt()` | Game state signals | `CanvasLayer`, `Label` |
| `SaveProgressionSystem` (Planned) | Foundation | Shift day, credits, upgrades, cassette archive | Save/load/shop APIs | Victory result | JSON/FileAccess |

---

## 5. Data Flow Architecture

### 1. Frame Update & Movement Loop
$$\text{Input Event} \xrightarrow{\text{Mouse Look}} \text{Head Rotation} \xrightarrow{\text{Velocity Calc}} \text{move\_and\_slide()} \xrightarrow{\text{Network Sync}} \text{Peer Remote Transform}$$

### 2. Remote Floodlight Trigger Event Loop
$$\text{Player Interacts with Button} \xrightarrow{\text{Local Validation}} \text{trigger\_sector\_light\_rpc(sector)} \xrightarrow{\text{ENet Broadcast}} \text{All Clients Execute} \begin{cases} \text{Start 10s Cooldown} \\ \text{Turn ON 45m SpotLight for 12s} \end{cases}$$

### 3. Shift Completion & Extraction Loop
$$\text{Field Repair 3 Antennas} \xrightarrow{\text{all\_damaged\_repaired}} \text{Unlock Main Switch} \xrightarrow{\text{Pull Switch}} \text{Open SignalDecoder UI} \xrightarrow{\text{A/D Frequency Match}} \text{Archive Cassette} \xrightarrow{\text{Current: Victory Screen}} \text{Planned: Credits \& Save JSON}$$

---

## 6. API Boundary Specifications

### `Player` Contract ([player.gd](file:///home/cem/Desktop/Nosignal/src/scripts/player.gd))
```gdscript
class_name Player extends CharacterBody3D

signal health_changed(current_health: float, max_health: float)
signal player_died()
signal focused_interactable_changed(interactable: Node3D)

func take_damage(amount: float) -> void
func _physics_process(delta: float) -> void
```

### `NetworkManager` Contract ([network_manager.gd](file:///home/cem/Desktop/Nosignal/src/scripts/network_manager.gd))
```gdscript
class_name NetworkManager extends Node

signal server_started()
signal client_connected()
signal player_joined(peer_id: int)

func create_host(port: int = 7777) -> Error
func join_game(address: String = "127.0.0.1", port: int = 7777) -> Error
```

### `TowerConsoleButton` Contract ([tower_console_button.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_console_button.gd))
```gdscript
class_name TowerConsoleButton extends Interactable

@rpc("any_peer", "call_local", "reliable")
func request_trigger() -> void
```

---

## 7. ADR Audit & Requirements Traceability Matrix

### ADR Audit Table
| ADR ID | Title | Status | Engine Version | GDD Linkage | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ADR-001** | Peer-to-Peer Listen Server Architecture | Accepted | Godot 4.7.1 | `multiplayer-netcode-system` | ✅ **APPROVED** |
| **ADR-002** | 3D Spatial Audio & Voice Bus Routing | Proposed (document not yet present) | Godot 4.7.1 | `radio-communication-system` | ⚪ **PLANNED** |
| **ADR-003** | JSON Save Data Serialization & Shift Economy | Proposed (document not yet present) | Godot 4.7.1 | `save-progression-system` | ⚪ **PLANNED** |

### Requirements Traceability Matrix
- `TR-player-001` to `TR-player-003` $\to$ Covered by `Player` class & `player-controller-fps.md`.
- `TR-netcode-001` to `TR-netcode-003` $\to$ Covered by **ADR-001** & `network_manager.gd`.
- `TR-flashlight-001` to `TR-flashlight-002` $\to$ Covered by `Flashlight` class & `flashlight-power-system.md`.
- `TR-antennae-001` to `TR-antennae-002` $\to$ Covered by `ForestAntennaManager` & `forest-antennae-system.md`.
- `TR-terminal-001` to `TR-terminal-004` $\to$ Covered by `TowerRadar`, `TowerConsoleButton`, `SignalDecoder`.
- `TR-anomaly-001` to `TR-anomaly-003` $\to$ Covered by `AnomalyThreat` AI & `anomaly-entity-ai.md`.
- `TR-ui-001` to `TR-ui-002` $\to$ Covered by `HUD`, `LobbyUI`, `diegetic-ui-system.md`.
- `TR-radio-001` $\to$ Covered by **ADR-002** & `radio-communication-system.md`.
- `TR-save-001` to `TR-save-003` $\to$ Covered by **ADR-003** & `save-progression-system.md`.

---

## 8. Architecture Principles

1. **Server Authority (ADR-001):** Host server calculates entity damage, item pickups, and shift state to prevent multiplayer desynchronization.
2. **Diegetic Immersion:** All UI elements, indicators, and controls render as world objects or CRT monitors.
3. **Decoupled Event Signals:** Nodes communicate via Godot signals (`connect()`) and reliable RPCs (`@rpc`), avoiding hardcoded parent/child assumptions.
4. **Crash-Safe Persistence (Planned):** Save files will write atomically to `user://save_data.json` with fallback backup files (`user://save_data.bak`).
