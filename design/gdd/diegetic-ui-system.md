# GDD: Diegetic UI System (`diegetic-ui-system`)

> **Status**: Partially Implemented (Prototype; team outcome and presentation polish pending)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`CanvasLayer` + GDScript)
> **Implements Pillar**: Pillar 2 (Asymmetric Dependency) & Pillar 3 (Retro PSX Aesthetics)
> **Source Code**: [hud.gd](file:///home/cem/Desktop/Nosignal/src/scripts/hud.gd), [lobby_ui.gd](file:///home/cem/Desktop/Nosignal/src/scripts/lobby_ui.gd)

---

## 0. Current Implementation Note

The prototype HUD, lobby, prompts, health/battery/stealth/radio labels, multiplayer debug overlay, and end screens exist. Team-wipe semantics, production debug gating, and final diegetic presentation polish remain pending.

## 1. Overview

**Diegetic UI System (`diegetic-ui-system`)** manages the heads-up presentation, interaction prompts, stealth safety labels, battery/health progress bars, multiplayer lobby overlay, and end-of-shift game state screens in **Signal Array 04**. Designed to maintain retro PSX immersion, UI elements render unobtrusively using CRT phosphor green (`#00FF66`), warning amber (`#FFB000`), and crimson red (`#D92B2B`) color overrides.

---

## 2. Player Fantasy

The interface feels like an authentic retro monitoring suite—displaying diegetic feedback such as `"STEALTH: HIDDEN [SAFE]"`, `"RADIO SIGNAL: BEEPING [75% FREQUENCY LOCK]"`, or `"SIGNAL LOST - GAME OVER"`. The UI guides players without cluttering the claustrophobic 3D camera view.

---

## 3. Detailed Rules

1. **HUD Elements (`hud.gd`):**
   - Prompt Label: Displays interaction prompts (e.g., `"Hold [E] to Repair Antenna Array #1"`).
   - Battery Progress Bar: Binds to `flashlight.battery_changed` signal.
   - Health Progress Bar: Binds to `player.health_changed` signal (0–100 HP).
   - Stealth Label: Displays `"STEALTH: HIDDEN [SAFE]"` in green when crouching with flashlight OFF; otherwise `"STEALTH: EXPOSED [ANOMALY RISKS]"` in amber.
   - Radio Status Label: Displays signal strength beeping in green or heavy static warning in red.
   - Antenna Status Counter: Displays repaired count (e.g., `"ANTENNA ARRAYS: 2 / 3 ONLINE"`).
2. **Lobby UI Overlay (`lobby_ui.gd`):**
   - High render layer (`layer = 10`).
   - Features "Host Shift (Operator)", "Join Shift", address input field, and connection status label.
   - Sets `Input.mouse_mode = MOUSE_MODE_VISIBLE` while active; hides panel and captures mouse upon host/join request.
3. **Overlay Panels (Game Over / Victory):**
   - Game Over: Title `"SIGNAL LOST - GAME OVER"`, Subtitle `"An anomaly consumed your team. Press [R] to Restart."`.
   - Victory: Title `"SHIFT COMPLETE - EXTRACTION SUCCESSFUL!"`, Subtitle `"Signal locked & Observatory secured! Press [R] to Replay."`.

---

## 4. Formulas

### Signal Percentage Conversion Formula
$$\text{SignalPct}(d_{antenna}) = \text{clamp}\left( \left\lfloor \left(1.0 - \frac{d_{antenna}}{15.0}\right) \times 100 \right\rfloor, 10, 100 \right)$$

---

## 5. Edge Cases

- **Mouse Cursor Trapping in Lobby:** If `LobbyUI` panel is visible, `_unhandled_input` enforces `MOUSE_MODE_VISIBLE` even if user clicks on 3D background.
- **Scene Reload on R Key:** Pressing R key during `GAME_OVER` or `VICTORY` state triggers `get_tree().reload_current_scene()`.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Sends health updates and focused interactable prompts.
- [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md): Sends battery updates.
- [`forest-antennae-system`](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md): Sends repaired antenna count updates.

### Downstream Dependents (Depends On This System)
- [`tower-terminal-system`](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md): Renders decoder UI overlays.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `layer` | 10 | 1 – 100 | CanvasLayer render z-index priority |
| `prompt_fade_speed` | 10.0 | 5.0 – 20.0 | Smooth prompt label appearance rate |
| `radio_max_distance` | 15.0 m | 5.0 – 30.0 | Maximum distance for radio beeping display |

---

## 8. Acceptance Criteria

- **GIVEN** a player crouching with flashlight OFF, **WHEN** `update_stealth_status` executes, **THEN** stealth label displays `"STEALTH: HIDDEN [SAFE]"` in green.
- **GIVEN** player health reaching 0, **WHEN** `_on_player_died` fires, **THEN** overlay panel shows `"SIGNAL LOST - GAME OVER"` and mouse cursor becomes visible.
- **GIVEN** a user clicking Host Shift button in `LobbyUI`, **WHEN** `_on_host_pressed` runs, **THEN** host request signal emits and lobby panel hides.
