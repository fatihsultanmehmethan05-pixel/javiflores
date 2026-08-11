# Signal Array 04 — Implementation Guide and Roadmap

> **Target Platform:** PC / Steam
> **Engine Version:** Godot Engine 4.7.1 (`Forward+`)
> **Architecture:** Host-as-server listen model (`ADR-001`)
> **Current Stage:** Multiplayer vertical-slice stabilization
> **Roadmap Policy:** Planned scope is preserved for evaluation; unchecked items are not implementation claims.

## Roadmap Summary

```text
Prototype Workstream 1: Procedural Spawns and Dynamic Map (PARTIAL)
Prototype Workstream 2: Observatory Terminal and Signal Archive (PARTIAL)
Phase 3: Multiplayer Networking and Dynamic Role Scaling (ENET PROTOTYPE; STEAM PENDING)
Phase 4: Sanity, Weather, and Atmospheric Audio Polish (PLANNED)
Phase 5: Shift Economy and Tower Equipment Shop (PLANNED)
```

## Prototype Workstream 1: Procedural Spawns and Dynamic Map

**Goal:** Reduce predictable static layouts and make forest exploration vary by session.

- [x] **Multi-Antenna Node Array:** Place 8 candidate antenna nodes across the forest map.
- [x] **Procedural Shift Initializer (`ForestAntennaManager.gd`):** Select 3 damaged antennas and 5 operational antennas. Current multiplayer initialization still needs authoritative convergence/late-join validation.
- [ ] **Dynamic Anomaly Waypoints (`AnomalySpawner.gd`):** Spawn patrol paths near active/damaged antennas instead of static coordinates.

## Prototype Workstream 2: Observatory Terminal and Signal Archive

**Goal:** Support the Signal Researcher fantasy beyond simple button pressing.

- [x] **Observatory Radar Screen (`TowerRadar.tscn`):** Display live malfunctioning-antenna blips.
- [x] **Signal Frequency Decoder (`SignalDecoder.gd`):** Provide the frequency-matching mini-game. Its target, progress, result, and victory flow still need one authoritative multiplayer owner.
- [ ] **Signal Audio Log Archive:** Build a collectible cassette library with 20+ cosmic signals, distress calls, and former researcher logs.

## Phase 3: Multiplayer Networking and Dynamic Role Scaling

**Goal:** Stabilize the four-player host-as-server vertical slice and prepare transport abstraction for Steam.

- [x] **ENet Listen Server (`NetworkManager.gd`):** Host/join flow, deterministic peer-named player spawning, and local input/camera ownership.
- [x] **Replication Foundation:** `MultiplayerSpawner`, `MultiplayerSynchronizer`, and host-validated interaction requests for the current prototype.
- [ ] **Authoritative Session State:** Make objectives, decoder, anomaly AI, team outcome, disconnect/reconnect, and late join converge on one host-owned state.
- [ ] **Repeatable Multiplayer QA:** Add headless bots, metrics, stress/soak/churn scenarios, network conditioning, and acceptance thresholds.
- [ ] **Steam Lobby/Relay Integration:** Add GodotSteam binaries, lobby creation/join/invites, relay transport, adapter wiring, and shipping validation.

## Phase 4: Sanity, Weather, and Atmospheric Audio Polish

**Goal:** Increase replay variety and tension through environmental mutators and spatial sound.

- [ ] **Heavy Breathing / Sanity Meter:** Crouching in darkness for more than 8 seconds triggers breathing audio and threat consequences.
- [ ] **Bush and Twig Rustle Physics:** Movement through vegetation creates sound that can alert anomalies.
- [ ] **Random Shift Mutators:**
  - Dense Fog Night: visibility reduced to 2 meters.
  - Electromagnetic Storm: flashlight flicker and increased radio interference.
  - Blood Moon Shift: anomalies move 20% faster and signal rewards double.
- [ ] **Spatial Audio Engine:** Add surface footsteps, ambient storm acoustics, radio interference, and positional walkie-talkie behavior.

## Phase 5: Shift Economy and Tower Equipment Shop

**Goal:** Establish longer-term progression across multi-night shifts after the core multiplayer loop is stable.

- [ ] **Night Shift Progression:** Implement Day 1 through Day 3 with escalating weather and anomaly pressure.
- [ ] **Credit Rewards:** Award credits based on signal quality and successful extraction.
- [ ] **Tower Supply Shop (`TowerShop.tscn`):** Evaluate and implement high-capacity batteries, deployable motion sensors, an emergency flare gun, and radio upgrades.
- [ ] **Persistence:** Add versioned, atomic JSON save/load and define team-versus-player ownership.
- [ ] **Economy Validation:** Define replenishment, repeatable sinks, casualty/flawless rules, player-count scaling, and anti-dominant-strategy balance.

## Completed Pre-Production and Architecture Records

- [x] Game concept document
- [x] Art Bible specification
- [x] Systems decomposition index
- [x] Player controller system specification
- [x] ADR-001 listen-server architecture decision
- [x] MVP prototype: FPS controller, repair loop, anomaly prototype, extraction loop, and tower switch

See the [current implementation alignment review](../design/gdd/gdd-implementation-alignment-2026-08-11.md) for verified gaps and priorities.
