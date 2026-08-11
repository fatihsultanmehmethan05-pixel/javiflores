# GDD: Save & Progression System (`save-progression-system`)

> **Status**: Designed / Not Implemented (Roadmap Phase 5)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`ResourceSaver` / JSON + GDScript)
> **Implements Pillar**: Pillar 2 (Asymmetric Dependency) & Progression Loop
> **Source Code**: [main_game.gd](file:///home/cem/Desktop/Nosignal/src/scripts/main_game.gd), [signal_decoder.gd](file:///home/cem/Desktop/Nosignal/src/scripts/signal_decoder.gd)

---

## 0. Current Implementation Note

This document is an approved roadmap design, not a description of current code. The prototype currently stores only the decoded cassette title for the active session and shows victory; credits, save files, multi-night progression, shop inventory, upgrades, and recovery backups are not implemented.

## 1. Overview

**Save & Progression System (`save-progression-system`)** governs long-term shift progression, credit rewards ($), cassette audio log collection, and tower supply shop purchasing across multi-night shifts (`Day 1 -> Day 2 -> Day 3`) in **Signal Array 04**. Successful signal extractions award credits based on decoded signal quality, allowing players to buy high-capacity batteries, flare guns, and motion sensors before advancing to escalating weather difficulty shifts.

---

## 2. Player Fantasy

Players experience the career progression of remote observatory researchers. Successfully archiving cosmic signals and extracting alive yields funding to upgrade equipment, purchase flare guns for self-defense, install automated motion sensors on antenna poles, and face increasingly severe EM storms on subsequent night shifts.

---

## 3. Detailed Rules

1. **Multi-Night Shift Progression (`Day 1 -> Day 2 -> Day 3`):**
   - Shift 1 (Day 1): Standard night storm, 3 damaged antennas, normal anomaly speed (2.4 m/s).
   - Shift 2 (Day 2): EM Storm mutator, flashlights flicker randomly, anomaly patrol speed increases to 2.7 m/s.
   - Shift 3 (Day 3): Blood Moon mutator, visibility reduced, 4 damaged antennas, doubled credit rewards ($).
2. **Credit Earnings Formula:**
   - Base Shift Completion: **$150**.
   - Decoded Signal Bonus: **+$100** per archived cassette log.
   - Zero Casualties Bonus: **+$50**.
3. **Tower Supply Shop (`TowerShop.tscn`):**
   - Accessible via observatory terminal interface between shifts.
   - **High-Capacity Battery Kit ($75):** Increases `max_battery` from 100 to 200 units (250s burn time).
   - **Deployable Motion Sensor ($120):** Places sensor on antenna pole that transmits red blips to `TowerRadar` when anomaly passes within 10m.
   - **Emergency Flare Gun ($180):** Single-use flare projectile that illuminates a 20m area and stuns anomalies for 6.0 seconds.
4. **Save Data Serialization:**
   - Saved locally to `user://save_data.json`.
   - Stores `shift_day`, `credits`, `purchased_upgrades`, and `archived_cassettes` array.

---

## 4. Formulas

### 1. Shift Reward Calculation
$$\text{Credits}_{reward} = \text{Base} + (\text{Cassettes} \times 100) + \text{Bonus}_{flawless}$$
- $\text{Base} = 150 \cdot \text{ShiftDayMultiplier}$ (Day 1 = 1.0, Day 2 = 1.25, Day 3 = 2.0).

### 2. Upgraded Flashlight Duration
$$T_{burn} = \frac{\text{max\_battery}}{r_{drain}} = \frac{200}{0.8} = 250 \text{ seconds}$$

---

## 5. Edge Cases

- **Team Wipe / Game Over:** If all players die before extraction, shift fails; progression resets to Day 1 start, but unlocked cosmic cassette logs remain archived in the player's logbook.
- **Corrupted Save File:** If `user://save_data.json` fails JSON parsing on load, system backs up broken file to `user://save_data.bak` and reinitializes fresh Day 1 save state.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`tower-terminal-system`](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md): Supplies decoded signal cassette titles.
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Receives upgraded battery and tool items.

### Downstream Dependents (Depends On This System)
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Displays earned credits and shop interface.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `base_shift_reward` | $150 | $50 – $500 | Base payout for completing a shift |
| `cassette_bonus` | $100 | $25 – $250 | Bonus per decoded signal cassette |
| `battery_upgrade_cost` | $75 | $25 – $200 | Price of high-capacity battery in shop |
| `flare_gun_cost` | $180 | $50 – $400 | Price of single-use flare gun in shop |

---

## 8. Acceptance Criteria

- **GIVEN** a player completing Shift 1 with 1 decoded cassette, **WHEN** extraction finishes, **THEN** $250 credits are awarded and saved to `user://save_data.json`.
- **GIVEN** a player purchasing High-Capacity Battery Kit in Tower Shop, **WHEN** next shift starts, **THEN** player flashlight `max_battery` equals 200 units.
- **GIVEN** team dying during Shift 2, **WHEN** game over screen triggers, **THEN** shift day resets to Day 1 while collected cassette log library remains intact.
