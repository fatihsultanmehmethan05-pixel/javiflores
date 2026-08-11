# GDD: Radio Communication System (`radio-communication-system`)

> **Status**: Partially Implemented (HUD proximity feedback only; spatial audio and voice planned)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`AudioStreamPlayer3D` + GDScript)
> **Implements Pillar**: Pillar 1 (Spatial Audio Suspense) & Pillar 2 (Asymmetric Dependency)
> **Source Code**: [main_game.gd](file:///home/cem/Desktop/Nosignal/src/scripts/main_game.gd), [hud.gd](file:///home/cem/Desktop/Nosignal/src/scripts/hud.gd)

---

## 0. Current Implementation Note

Distance calculations and HUD text feedback for antenna beeping and threat static are implemented. AudioStreamPlayer3D playback, surface footsteps, positional voice chat, and Steam voice routing remain roadmap work.

## 1. Overview

**Radio Communication System (`radio-communication-system`)** manages directional audio cues, radio static noise warnings, signal frequency proximity beeping, and spatial walkie-talkie communication in **Signal Array 04**. Operating via `_process_radio_proximity()` in `MainGame`, it continuously measures distance to unfixed antennas and nearby anomaly threats, driving diegetic HUD text and 3D spatial acoustics.

---

## 2. Player Fantasy

The walkie-talkie radio is the field investigator's primary sensory link to the world. As an anomaly approaches in pitch-black fog, normal radio hum breaks into terrifying crackling static. Conversely, getting close to an unlit damaged antenna produces rhythmic radio frequency beeping that helps guide blind exploration.

---

## 3. Detailed Rules

1. **Threat Proximity Static (Distance $< 12.0\text{m}$):**
   - When closest `AnomalyThreat` distance $d_{threat} < 12.0\text{m}$, radio static overrides all signals.
   - HUD label displays `"RADIO: !!! HEAVY STATIC NOISE (THREAT NEARBY) !!!"` in crimson red (`#D92B2B`).
   - Plays 3D audio static loop.
2. **Antenna Proximity Beeping (Distance $< 15.0\text{m}$):**
   - When no threat is nearby ($d_{threat} \ge 12.0\text{m}$) and closest unfixed antenna distance $d_{antenna} < 15.0\text{m}$, radio beeps rhythmically.
   - Signal lock percentage scales inversely with distance ($10\%$ at 15m to $100\%$ at 0m).
   - HUD label displays `"RADIO SIGNAL: BEEPING [XX% FREQUENCY LOCK]"` in phosphor green (`#00FF66`).
3. **Ambient Baseline (Distance $\ge 15.0\text{m}$):**
   - HUD label displays `"RADIO: LOW FREQUENCY HUM"` in gray (`#AAAAAA`).
4. **Spatial Audio Architecture (Phase 4 Roadmap):**
   - `AudioStreamPlayer3D` handles surface-dependent footstep sound effects (`footstep_grass.wav`, `footstep_concrete.wav`, `footstep_wood.wav`).
   - Positional walkie-talkie voice chat audio uses attenuation curves (`attenuation_model = ATTENUATION_INVERSE_DISTANCE`).

---

## 4. Formulas

### 1. Distance Proximity Evaluation
$$d_{antenna} = \min_{i \in \text{Antennas}} \|\mathbf{P}_{player} - \mathbf{P}_{antenna, i}\|$$
$$d_{threat} = \min_{j \in \text{Threats}} \|\mathbf{P}_{player} - \mathbf{P}_{threat, j}\|$$

### 2. Frequency Signal Lock Percentage
$$\text{LockPct}(d_{antenna}) = \text{clamp}\left( \left\lfloor \left(1.0 - \frac{d_{antenna}}{15.0}\right) \cdot 100 \right\rfloor, 10, 100 \right)$$

---

## 5. Edge Cases

- **Simultaneous Threat & Antenna Proximity:** Threat static ($<12\text{m}$) strictly takes priority over antenna beeping ($<15\text{m}$) to warn player of immediate mortal danger.
- **All Antennas Repaired:** When all antennas are operational, antenna proximity scan returns $\infty$, leaving radio in low frequency hum or threat static state.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Supplies local player position.
- [`forest-antennae-system`](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md): Supplies unfixed antenna array positions.
- [`anomaly-entity-ai`](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md): Supplies anomaly threat positions.

### Downstream Dependents (Depends On This System)
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Renders radio status text on HUD.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `threat_static_distance` | 12.0 m | 5.0 – 20.0 | Distance threshold for heavy radio static |
| `antenna_beep_distance` | 15.0 m | 5.0 – 30.0 | Distance threshold for signal beeping |
| `audio_bus_volume` | 0.0 dB | -24.0 – +6.0 | Walkie-talkie audio channel gain |

---

## 8. Acceptance Criteria

- **GIVEN** an anomaly walking within 8m of player, **WHEN** `_process_radio_proximity` updates, **THEN** HUD displays red heavy static warning.
- **GIVEN** a player standing 6m from an unfixed antenna with no threats near, **WHEN** radio updates, **THEN** HUD displays green beeping with ~60% frequency lock.
- **GIVEN** a player over 15m away from all threats and unfixed antennas, **WHEN** radio updates, **THEN** HUD displays gray low frequency hum.
