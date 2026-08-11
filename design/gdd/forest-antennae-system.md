# GDD: Forest Antennae System (`forest-antennae-system`)

> **Status**: Partially Implemented (Prototype; repair interruption/decay feedback pending)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`Node3D` + `OmniLight3D` + GDScript)
> **Implements Pillar**: Pillar 2 (Asymmetric Dependency) & Pillar 3 (Retro Aesthetics)
> **Source Code**: [forest_antenna_manager.gd](file:///home/cem/Desktop/Nosignal/src/scripts/forest_antenna_manager.gd), [antenna_panel.gd](file:///home/cem/Desktop/Nosignal/src/scripts/antenna_panel.gd), [fuse_pickup.gd](file:///home/cem/Desktop/Nosignal/src/scripts/fuse_pickup.gd)

---

## 0. Current Implementation Note

Server-selected 3-of-8 antenna state, fuse pickup, standing repair validation, and late-join snapshots are implemented. Repair-progress decay after release, damage interruption, and the full contextual prompt set remain pending.

## 1. Overview

**Forest Antennae System (`forest-antennae-system`)** governs the procedural selection, placement, fuse requirements, and repair mechanics of antenna arrays distributed across the 300m² forest in **Signal Array 04**. At the start of each shift, `ForestAntennaManager` randomly designates 3 candidate antenna arrays as damaged/unlit while setting the remaining candidate nodes as operational. Field engineers must locate Electrical Fuse Kits in forest cabins and hold E for 1.5 seconds while standing to complete repairs.

---

## 2. Player Fantasy

Navigating dark woods guided only by subtle wire lines, investigators experience intense tension when approaching damaged, unlit antenna arrays. Players must coordinate tasks—one holding a flashlight and searching for missing fuse kits, another holding E to install fuses while standing exposed to potential anomaly attacks.

---

## 3. Detailed Rules

1. **Procedural Shift Initializer:**
   - On `_ready()`, `ForestAntennaManager` gathers all `AntennaPanel` children.
   - Shuffles the candidate array on the host and synchronizes the selected names, then selects `damaged_antenna_count = 3` as **DAMAGED** (unlit, `is_fixed = false`).
   - Remaining candidate nodes (5 nodes) are set to **OPERATIONAL** (bright green light, `is_fixed = true`).
2. **Electrical Fuse Kit Requirement:**
   - Repairing a damaged antenna array requires an **Electrical Fuse Kit** (`FusePickup.tscn`).
   - Players pick up fuses by interacting with `FusePickup` nodes (`player.has_fuse = true`).
   - If player attempts repair without a fuse, prompt reads: `"FUSE MISSING! Search forest cabins for Fuse Kit [E]"`.
3. **Standing Repair Rule:**
   - Repair duration (`repair_duration`): **1.5 seconds**.
   - If player attempts repair while crouching (`current_state == CROUCHING`), repair progress pauses and prompt displays `"MUST STAND UP TO REPAIR! [E]"`.
   - Releasing E key decays progress back to 0.0 at rate $2.0 \cdot \Delta t$.
4. **Completion & Consumption:**
   - Upon reaching 100% progress (1.5s hold), fuse is consumed (`player.has_fuse = false`), antenna lights glow phosphor green (`#00FF66`, energy = 2.5), and `antenna_status_changed` signal is emitted.
   - When all 3 damaged antennas are fixed, `all_damaged_repaired` signal triggers `EXTRACTION_PHASE`.

---

## 4. Formulas

### 1. Repair Progress Calculation
$$P(t) = \begin{cases} \min\left(P_{prev} + \Delta t, 1.5\right) & \text{if } E_{held} \land \text{has\_fuse} \land \neg \text{is\_crouching} \\ \max\left(P_{prev} - 2.0 \cdot \Delta t, 0.0\right) & \text{otherwise} \end{cases}$$

### 2. Completion Percentage
$$\text{Percent}(t) = \left\lfloor \frac{P(t)}{1.5} \times 100 \right\rfloor$$

---

## 5. Edge Cases

- **Interrupted Repair:** If player takes damage from an anomaly while holding E, repair progress decays; player can resume once threat retreats if fuse is still held.
- **Multiple Players Attempting Repair:** Each `AntennaPanel` tracks `repairing_player`; server authority resolves simultaneous interactions.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Reads `player.has_fuse` and crouching state.
- [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md): Illuminates unlit panels in dark fog.

### Downstream Dependents (Depends On This System)
- [`tower-terminal-system`](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md): CRT Radar display renders directions of damaged antennas.
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): HUD updates repaired antenna counter (e.g., `0 / 3 ONLINE`).

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `damaged_antenna_count` | 3 | 1 – 6 | Number of damaged antennas per shift |
| `repair_duration` | 1.5 s | 1.0 – 5.0 | Hold-E repair time requirement |
| `requires_fuse` | true | true / false | Toggles fuse kit requirement |
| `decay_rate` | 2.0 /s | 0.5 – 5.0 | Rate progress decays when E is released |

---

## 8. Acceptance Criteria

- **GIVEN** a shift starting, **WHEN** `ForestAntennaManager` initializes, **THEN** exactly 3 antenna panels are set unlit damaged and 5 set operational green.
- **GIVEN** a player without a fuse kit holding E at a damaged antenna, **WHEN** progress updates, **THEN** prompt displays "FUSE MISSING!" and progress remains at 0%.
- **GIVEN** a player with a fuse kit holding E while standing for 1.5 seconds, **WHEN** repair completes, **THEN** fuse is consumed, status light turns green, and repaired count increments.
