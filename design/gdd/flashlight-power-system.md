# GDD: Flashlight Power System (`flashlight-power-system`)

> **Status**: Implemented (Prototype)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`SpotLight3D` + GDScript)
> **Implements Pillar**: Pillar 1 (Spatial Suspense) & Pillar 3 (Retro PSX Aesthetics)
> **Source Code**: [flashlight.gd](file:///home/cem/Desktop/Nosignal/src/scripts/flashlight.gd)

---

## 0. Current Implementation Note

Battery drain, toggle replication, exhaustion, and low-battery visuals are implemented for the prototype. Upgrade-driven capacity changes remain part of the Phase 5 progression roadmap.

## 1. Overview

**Flashlight Power System (`flashlight-power-system`)** manages the hand-held `SpotLight3D` flashlight carried by player characters in **Signal Array 04**. It handles smooth battery depletion over time, low-battery warning flicker effects ($\le 20\%$), RPC network synchronization across multiplayer peers, light energy scaling, and direct visibility integration with the anomaly threat stealth sensor.

---

## 2. Player Fantasy

In the pitch-black 300m² forest, the flashlight is the field investigator's sole lifeline for locating unlit damaged antenna panels and navigating terrain. However, using the light creates severe vulnerability: the battery drains continuously, low energy triggers terrifying flickering, and an active beam exposes the player to roaming anomaly threats.

---

## 3. Detailed Rules

1. **Battery Capacity & Drain Rate:**
   - Maximum Battery (`max_battery`): **100.0 units**.
   - Drain Rate (`drain_rate`): **0.8 units/sec** (Full depletion in ~125 seconds of continuous use).
2. **Low-Battery Flicker Effect:**
   - Threshold (`low_battery_threshold`): **20.0 units**.
   - When $current\_battery \le 20.0$, `light_energy` flickers randomly between **0.8 and 2.5**.
   - Normal `light_energy`: **2.5**.
3. **Empty Battery Shutdown:**
   - When $current\_battery = 0.0$, `is_on` is forced to `false` and spotlight visibility is disabled.
4. **RPC Network Sync:**
   - The owning player toggles the flashlight via `apply_flashlight_state.rpc(!is_on)`; non-owning replicas do not read local input.
   - All connected peers update local spotlight node visibility accordingly.
5. **Stealth Sensor Exposure:**
   - An active flashlight (`is_on == true`) overrides crouching stealth, exposing the player to `AnomalyThreat` AI within 9.0m radius.

---

## 4. Formulas

### 1. Battery Depletion
$$B(t) = \max\left(B_{prev} - r_{drain} \cdot \Delta t, 0.0\right)$$
- $r_{drain} = 0.8 \text{ units/s}$.

### 2. Light Energy Flicker
$$E_{light} = \begin{cases} \text{randf\_range}(0.8, 2.5) & \text{if } B(t) \le 20.0 \\ 2.5 & \text{if } B(t) > 20.0 \end{cases}$$

---

## 5. Edge Cases

- **Battery Exhaustion during Interaction:** If battery hits zero while repairing an antenna, light extinguishes instantly; repair progress continues if E is held, but player becomes vulnerable to dark patrols.
- **Toggling while Dead:** Dead players (`_is_dead == true`) cannot issue flashlight RPC toggles.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Mounts flashlight to camera node (`$Head/Camera3D/Flashlight`).
- [`multiplayer-netcode-system`](file:///home/cem/Desktop/Nosignal/design/gdd/multiplayer-netcode-system.md): Replicates the owner-authoritative `apply_flashlight_state` result.

### Downstream Dependents (Depends On This System)
- [`anomaly-entity-ai`](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md): Reads `flashlight.is_on` to calculate player detection.
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Updates HUD battery progress bar.
- [`save-progression-system`](file:///home/cem/Desktop/Nosignal/design/gdd/save-progression-system.md): Supplies battery capacity upgrades at the tower shop.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `max_battery` | 100.0 | 50.0 – 300.0 | Maximum battery capacity |
| `drain_rate` | 0.8 /s | 0.2 – 2.0 | Depletion speed per second |
| `low_battery_threshold` | 20.0 | 10.0 – 40.0 | Threshold triggering flicker effect |
| `normal_light_energy` | 2.5 | 1.0 – 5.0 | Normal spotlight brightness energy |

---

## 8. Acceptance Criteria

- **GIVEN** an active flashlight with 100% battery, **WHEN** 125 seconds elapse, **THEN** battery reaches 0% and light extinguishes automatically.
- **GIVEN** battery level dropping to 18%, **WHEN** flashlight is on, **THEN** light energy randomly flickers between 0.8 and 2.5 every frame.
- **GIVEN** the owning player pressing F, **WHEN** `toggle()` is executed, **THEN** `apply_flashlight_state` updates that player’s flashlight across all peers without transferring input authority.
