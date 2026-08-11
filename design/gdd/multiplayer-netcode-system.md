# GDD: Multiplayer Netcode System (`multiplayer-netcode-system`)

> **Status**: Implemented (ENet Prototype); Steam P2P Integration Planned
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`ENetMultiplayerPeer` + GDScript)
> **Architecture Record**: [ADR-001 Peer-to-Peer Listen Server](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md)
> **Source Code**: [network_manager.gd](file:///home/cem/Desktop/Nosignal/src/scripts/network_manager.gd), [lobby_ui.gd](file:///home/cem/Desktop/Nosignal/src/scripts/lobby_ui.gd)

---

## 0. Current Implementation Note

ENet listen-server hosting, deterministic custom spawning, lifecycle cleanup, server-authoritative world interactions, and local camera/input ownership are implemented. Steam transport is represented by an optional adapter only; Steam lobby, invite, relay initialization, and shipping binaries remain planned. Decoder/victory state still requires a single authoritative multiplayer owner.

## 1. Overview

**Multiplayer Netcode System (`multiplayer-netcode-system`)** provides host-as-server peer-to-peer multiplayer networking for 1 to 4 players in **Signal Array 04**. Built on Godot 4 `ENetMultiplayerPeer`, it manages host creation on port 7777, client connections, dynamic peer character spawning, authority assignment (`set_multiplayer_authority(peer_id)`), and reliable RPC broadcasting for sector floodlights, console buttons, and flashlight toggles.

---

## 2. Player Fantasy

Players experience co-op where one player hosts as Station Commander and up to three peers join as field personnel. The current ENet transport supports LAN and direct-IP testing and may require router configuration for internet play. Port-free Steam friend joining remains a planned GodotSteam lobby and relay integration.

---

## 3. Detailed Rules

1. **Host-as-Server Listen Model (ADR-001):**
   - Host operates server logic and client 1 (`peer_id = 1`) simultaneously.
   - Server holds authority (`multiplayer.is_server()`) over procedural antenna states, anomaly AI navigation, and health calculations.
2. **Server Creation & Joining:**
   - Default Port: `7777`, Max Players: `4`.
   - Host Spawning Position: `Vector3(-1.2, 0.0, 1.0)` near tower foot.
   - Client spawning positions are assigned by stable join index at 0.8m offsets around the tower foot; raw ENet peer IDs are not used as world coordinates.
3. **Multiplayer Authority Assignment:**
   - Node naming convention: Player instances are named after stringified `peer_id` (e.g., `"1"`, `"2"`).
   - In `_enter_tree()`, each player node calls `set_multiplayer_authority(name.to_int())`.
   - Camera and local input require node name, local peer ID, and multiplayer authority to match. Player cameras start inactive; only the local player calls `make_current()`.
4. **RPC Communication Specification:**
   - Clients send intent requests to the host; the host validates sender identity, proximity, ownership, inventory, and state.
   - Authoritative results use authority-only apply RPCs such as `apply_flashlight_state`, `apply_cooldown`, and `apply_active`.
   - Player identity, position, and authority are supplied through `MultiplayerSpawner.spawn(data)` before scene-tree entry.

---

## 4. Formulas

### Peer Spawn Offset Formula
For stable join index `i` starting at 1:

```text
spawn_position(i) = (-1.2 + 0.8 * (i - 1), 0.0, 1.0)
```

Peer IDs remain identity keys and are never multiplied into world coordinates.

---

## 5. Edge Cases

- **Host Disconnection:** Clients receive `server_disconnected`; network peers and player nodes are cleared and the lobby is restored. Host migration is not implemented.
- **Duplicate Spawn Prevention:** The host checks `PlayersContainer` before calling the custom `MultiplayerSpawner.spawn(data)` path.
- **Client Disconnection Cleanup:** On `peer_disconnected(id)`, `queue_free()` is invoked on the disconnected peer's node tree across all remaining peers.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- None (Foundation System Layer 1).

### Downstream Dependents (Depends On This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Sets authority and replicates transforms.
- [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md): Uses RPCs for flashlight sync.
- [`tower-terminal-system`](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md): Uses RPCs for remote sector floodlight triggers.
- [`radio-communication-system`](file:///home/cem/Desktop/Nosignal/design/gdd/radio-communication-system.md): Routes 3D audio streams across connected peers.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `DEFAULT_PORT` | 7777 | 1024 – 65535 | ENet network listening port |
| `MAX_PLAYERS` | 4 | 1 – 8 | Maximum lobby capacity |
| `spawn_offset_x` | 0.8 m | 0.5 – 3.0 | Distance between spawned player capsules |

---

## 8. Acceptance Criteria

- **GIVEN** a player clicking "Host Shift", **WHEN** `create_host()` runs, **THEN** server starts on port 7777 and spawns player 1 at `(-1.2, 0.0, 1.0)`.
- **GIVEN** a client connecting via IP address, **WHEN** `join_game()` succeeds, **THEN** host spawns client character and assigns peer authority.
- **GIVEN** any peer pressing F key, **WHEN** `toggle()` triggers RPC, **THEN** flashlight visibility updates synchronously on all peers.
