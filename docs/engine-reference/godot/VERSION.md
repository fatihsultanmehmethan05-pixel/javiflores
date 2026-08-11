# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7.1 |
| **Language** | GDScript |
| **Project Pinned** | 2026-08-10 |
| **Engine Executable Path** | `/home/cem/Apps/Godot` |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | MEDIUM — Godot 4.7 is beyond standard training cutoff |

## Version Notes (Godot 4.7.1)

- **TileMapLayer Migration:** Use `TileMapLayer` nodes instead of the deprecated monolithic `TileMap` node.
- **Audio API:** Use `AudioStreamPlayer3D` with attenuation model for spatial voice and sound effects.
- **3D Lighting:** Godot 4.7 includes `AreaLight3D` and updated 3D rendering performance.
- **UI Control Transforms:** Updated Control offset handling and container focus navigation.
- **Networking:** High-level multiplayer uses `ENetMultiplayerPeer`, `MultiplayerSpawner`, and `MultiplayerSynchronizer`.

## Deprecated APIs & Migration Rules

| Deprecated Feature | Replacement |
|---|---|
| `TileMap` (Monolithic node) | `TileMapLayer` |
| `connect("signal", self, "method")` | `signal_name.connect(method_name)` |
| `yield()` | `await` |
| `export` annotation | `@export` |
