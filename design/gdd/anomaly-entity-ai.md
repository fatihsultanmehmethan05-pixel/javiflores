# GDD: Anomaly Entity AI (`anomaly-entity-ai`)

> **Status**: Partially Implemented (Prototype; multiplayer targeting and balance pending)
> **Author**: Solo Developer + Antigravity
> **Last Updated**: 2026-08-11
> **Engine**: Godot Engine 4.7.1 (`Area3D` + `OmniLight3D` + GDScript)
> **Implements Pillar**: Pillar 1 (Spatial Suspense) & Pillar 3 (Retro PSX Aesthetics)
> **Source Code**: [anomaly_threat.gd](file:///home/cem/Desktop/Nosignal/src/scripts/anomaly_threat.gd)

---

## 0. Current Implementation Note

Host-authoritative patrol, chase, damage, replication, and safe-phase retreat are implemented. Continuous closest-exposed-player selection, floodlight response, and final multiplayer balance remain pending.

## 1. Overview

**Anomaly Entity AI (`anomaly-entity-ai`)** is the primary hostile threat entity roaming the 300m² volumetric forest in **Signal Array 04**. Operating on an `Area3D` node with dynamic state machine logic, the anomaly patrols between random waypoints, detects unhidden players within a 9.0m radius, transitions through suspicious warning states, chases exposed targets, deals 12.0 damage/sec on contact, and automatically retreats to origin during safe phases (`DECODING_PHASE` and `VICTORY`).

---

## 2. Player Fantasy

The anomaly embodies cosmic horror stalking in pitch-black mist. Players hear heavy radio static intensity rise as the entity approaches. Survival relies on crouching quietly in the dark with flashlights switched off—holding breath while watching the purple indicator light shift to amber suspicion or crimson chase.

---

## 3. Detailed Rules

1. **AI Parameters:**
   - Movement Speed (`move_speed`): **2.4 m/s**.
   - Detection Radius (`detection_radius`): **9.0 m**.
   - Contact Damage (`damage_per_second`): **12.0 HP/sec** (contact distance $\le 2.0\text{m}$).
   - Patrol Radius (`patrol_radius`): **18.0 m** around spawn origin.
2. **Stealth Sensor Evaluation (`_check_player_hidden`):**
   - Player is considered **HIDDEN** if and only if:
     $$\text{is\_hidden} = (\text{current\_state} == \text{CROUCHING}) \land (\text{flashlight.is\_on} == \text{false})$$
   - Standing or turning on the flashlight immediately marks the player as **EXPOSED**.
3. **State Machine & Suspicion Timers:**
   - **PATROL State:** Indicator light = Deep Purple (`#4A00E0`, energy = 1.2). Picks random offset within 18m radius, waits 1.5s–3.0s at targets.
   - **SUSPICIOUS State:** Triggered when exposed player enters 9m radius for $< 1.2\text{s}$, or hidden player stays stationary near anomaly for $> 10.0\text{s}$. Indicator light = CRT Amber (`#FFB000`, energy = 2.0). Moves at 30%–40% speed toward player.
   - **CHASE State:** Triggered when exposed player remains in 9m radius for $\ge 1.2\text{s}$. Indicator light = Crimson Red (`#D92B2B`, energy = 3.5). Moves at 100% speed (2.4 m/s) directly toward player.
4. **Safe Phase Disengagement:**
   - During `DECODING_PHASE` or `VICTORY`, anomaly disengages chase/suspicion completely and retreats toward spawn origin at half speed.

---

## 4. Formulas

### 1. Distance & Contact Damage
$$D_{player} = \|\mathbf{P}_{anomaly} - \mathbf{P}_{player}\|$$
$$\text{Damage}(t) = \begin{cases} 12.0 \cdot \Delta t & \text{if } D_{player} \le 2.0 \land \text{is\_chasing} \\ 0.0 & \text{otherwise} \end{cases}$$

### 2. State Transition Logic
$$\text{State}(t) = \begin{cases} \text{RETREAT} & \text{if } \text{is\_safe\_phase}() \\ \text{CHASE} & \text{if } D_{player} \le 9.0 \land \neg \text{is\_hidden} \land t_{suspicion} \ge 1.2 \\ \text{SUSPICIOUS} & \text{if } D_{player} \le 9.0 \land ((\neg \text{is\_hidden} \land t_{suspicion} < 1.2) \lor t_{stationary} > 10.0) \\ \text{PATROL} & \text{otherwise} \end{cases}$$

---

## 5. Edge Cases

- **Safe Zone Transition mid-Chase:** If player pulls the main switch while being chased, anomaly instantly disengages and returns to forest patrol, protecting player during decoding.
- **Multiple Players in Range:** Anomaly targets the closest exposed player; if all are hidden, continues patrol.

---

## 6. Dependencies

### Upstream Dependencies (Depended On By This System)
- [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md): Reads player position, crouch state, and health.
- [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md): Reads flashlight `is_on` state.

### Downstream Dependents (Depends On This System)
- [`radio-communication-system`](file:///home/cem/Desktop/Nosignal/design/gdd/radio-communication-system.md): Generates heavy radio static noise on HUD when threat distance $< 12.0\text{m}$.
- [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md): Shows game over screen if player health drops to 0.

---

## 7. Tuning Knobs

| Variable Name | Default | Safe Range | Description |
| :--- | :--- | :--- | :--- |
| `move_speed` | 2.4 m/s | 1.5 – 4.5 | Anomaly chase movement velocity |
| `detection_radius` | 9.0 m | 5.0 – 15.0 | Sensor detection sphere radius |
| `damage_per_second` | 12.0 HP/s | 5.0 – 35.0 | Contact damage per second |
| `patrol_radius` | 18.0 m | 10.0 – 40.0 | Waypoint patrol wander boundary |

---

## 8. Acceptance Criteria

- **GIVEN** an exposed standing player with flashlight on entering 9m radius, **WHEN** 1.2 seconds elapse, **THEN** indicator light turns crimson red and anomaly chases at 2.4 m/s.
- **GIVEN** a player crouching with flashlight OFF within 9m, **WHEN** stationary timer is under 10 seconds, **THEN** anomaly continues patrol without chasing.
- **GIVEN** main game entering `DECODING_PHASE`, **WHEN** anomaly is active, **THEN** AI disengages chase and retreats to origin point.
