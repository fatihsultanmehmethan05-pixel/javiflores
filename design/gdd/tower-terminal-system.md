# GDD: Tower Terminal System (`tower-terminal-system`)

> **Status**: Partially Implemented (Prototype; authoritative multiplayer decoder pending)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`Label3D` + `CanvasLayer` + GDScript)
> **Implements Pillar**: Pillar 2 (Asymmetric Dependency) & Pillar 3 (Retro PSX Aesthetics)
> **Source Code**: [tower_radar.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_radar.gd), [tower_console_button.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_console_button.gd), [sector_floodlight.gd](file:///home/cem/Desktop/Nosignal/src/scripts/sector_floodlight.gd), [tower_switch.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_switch.gd), [signal_decoder.gd](file:///home/cem/Desktop/Nosignal/src/scripts/signal_decoder.gd)

---

## 0. Current Implementation Note

Radar, floodlight controls, switch, and the local frequency mini-game are playable. Decoder target/progress/victory are not yet server-authoritative, and floodlights do not yet affect anomaly behavior.

## 1. Overview

**Tower Terminal System (`tower-terminal-system`)** encompasses all observatory tower command desk displays, remote controls, and signal archiving interfaces in **Signal Array 04**. It includes:
1. **3D CRT Radar Monitor (`TowerRadar`):** Live terminal rendering cardinal direction blips (NORTH-EAST, WEST, etc.) of damaged antennas.
2. **Remote Sector Floodlight Console (`TowerConsoleButton`):** Direct sector buttons (NORTH, EAST, SOUTH, WEST) firing 45m high-intensity floodlight beams (12s active, 10s cooldown).
3. **Main Power Switch (`TowerSwitch`):** Unlocks upon repairing 3 antennas, triggering extraction lockdown.
4. **Signal Frequency Wavelength Decoder (`SignalDecoder`):** Terminal UI mini-game where players tune frequencies via A/D keys to match target wavelengths and archive cosmic audio log cassettes.

---

## 2. Player Fantasy

Operating from the elevated observatory tower, the Station Commander acts as mission control—monitoring CRT screen blips, communicating cardinal directions over radio static, providing tactical illumination during anomaly encounters, and locking cosmic radio transmissions into the observatory cassette archive.

---

## 3. Detailed Rules

### 1. 3D CRT Radar Monitor
- Updates continuously in `_process(delta)`.
- Calculates cardinal vector direction from tower origin to each damaged antenna:
  - $z < -5.0 \implies \text{NORTH}$, $z > 5.0 \implies \text{SOUTH}$
  - $x > 5.0 \implies \text{-EAST}$, $x < -5.0 \implies \text{-WEST}$
- CRT screen glow color: Amber (`#FFB000`, energy = 1.5) when damaged antennas exist; Phosphor Green (`#00FF66`, energy = 2.5) when all operational.

### 2. Remote 4-Button Sector Floodlight Console
- Buttons for 4 cardinal sectors: **NORTH**, **EAST**, **SOUTH**, **WEST**.
- Interacting sends `request_trigger.rpc_id(1)` to the host; the host validates proximity and cooldown, then applies the sector floodlight state.
- Floodlight Pole (`SectorFloodlight`): Activates Spotlight (45 energy) & OmniLight (15 energy) for `active_duration = 12.0s`.
- Button Cooldown (`cooldown_duration`): **10.0s**. Prompt displays remaining recharge seconds.

### 3. Main Power Switch & Extraction
- Initial State: Locked (`is_enabled = false`). Light color = Red (`#D92B2B`).
- Unlocks when `all_damaged_repaired` signal fires. Light color turns Green (`#00FF66`).
- Pulling switch opens `SignalDecoder` UI and sets `current_game_state = DECODING_PHASE`.

### 4. Wavelength Signal Decoder Mini-Game UI
- Controls: Press `A` / `D` or Left / Right arrows to shift `current_frequency` between $100.0\text{Hz}$ and $800.0\text{Hz}$ at rate $140.0\text{ Hz/s}$.
- Tolerance Window (`tolerance`): $\pm 15.0\text{ Hz}$ around `target_frequency`.
- Progress fill: When $|current - target| \le 15.0$, `match_progress` increases at $+60.0/\text{s}$; otherwise decays at $-30.0/\text{s}$.
- Reaching 100% progress locks a random cosmic signal cassette (e.g., `"Signal #04: Deep Space Pulsar"`) and completes shift victory.

---

## 4. Formulas

### 1. Directional Vector Mapping
$$\mathbf{D}_{cardinal} = \text{String}\left( \text{dir}_z \right) + \text{String}\left( \text{dir}_x \right)$$

### 2. Frequency Matching Progress
$$M(t) = \begin{cases} \min\left(M_{prev} + 60.0 \cdot \Delta t, 100.0\right) & \text{if } |f_{current} - f_{target}| \le 15.0 \\ \max\left(M_{prev} - 30.0 \cdot \Delta t, 0.0\right) & \text{if } |f_{current} - f_{target}| > 15.0 \end{cases}$$

---

## 5. Edge Cases

- **Exiting Mini-Game Early:** Pressing ESC (`ui_cancel`) closes `SignalDecoder` and returns mouse mode to `MOUSE_MODE_CAPTURED`, reverting game state to `EXTRACTION_PHASE`.
- **Anomalies during Decoding:** Anomaly AI automatically enters safe zone disengagement during `DECODING_PHASE`, preventing unfair attacks while typing.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`forest-antennae-system`](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md): Supplies damaged antenna node array to CRT Radar.
- [`multiplayer-netcode-system`](file:///home/cem/Desktop/Nosignal/design/gdd/multiplayer-netcode-system.md): Synchronizes sector button RPC calls across clients.

### Downstream Dependents (Depends On This System)
- [`anomaly-entity-ai`](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md): Safe zone disengages during `DECODING_PHASE`.
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Displays victory screen upon signal decode completion.
- [`save-progression-system`](file:///home/cem/Desktop/Nosignal/design/gdd/save-progression-system.md): Awards credits for decoded signal cassettes.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `cooldown_duration` | 10.0 s | 5.0 – 30.0 | Sector floodlight button recharge time |
| `active_duration` | 12.0 s | 5.0 – 25.0 | Active floodlight illumination duration |
| `tolerance` | 15.0 Hz | 5.0 – 30.0 | Signal decoder frequency match window |
| `tuning_speed` | 140.0 Hz/s | 50.0 – 300.0 | A/D key frequency adjustment rate |

---

## 8. Acceptance Criteria

- **GIVEN** damaged antennas in North-East sector, **WHEN** `TowerRadar` updates, **THEN** display label reads `[!] ANTENNA #X: DAMAGED (NORTH-EAST)` in amber light.
- **GIVEN** a player pressing E on North Sector button, **WHEN** RPC fires, **THEN** North floodlight illuminates with 45 energy for 12s and button enters 10s cooldown.
- **GIVEN** all antennas repaired, **WHEN** player pulls main power switch and tunes frequency within $\pm 15\text{Hz}$ of target, **THEN** progress fills to 100% and audio log cassette is archived.
