# 🎮 Game Concept Document: Signal Array 04

> **Version:** 0.2.0 (Expanded Prototype & Architectural Blueprint)
> **Author:** Solo Developer + Antigravity
> **Engine:** Godot Engine 4.7.1 (`Forward+` Renderer)
> **Genre:** Asymmetric Co-Op FPS Horror / Survival
> **Target Platform:** PC (Steam)
> **Visual Style:** Retro PSX / Low-Poly 3D + Volumetric Fog & CRT Shader
> **Architecture Record:** [ADR-001 Peer-to-Peer Listen Server](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md)

---

## 1. Executive Summary & Core Identity

**Signal Array 04** is an atmospheric, high-tension 4-player asymmetric co-op FPS horror game set in a remote signal observatory and a dense 300m² volumetric forest.

Players divide into two diegetic roles:
- **Station Commander (Tower Operator):** Remains inside the central observatory tower, operating the 3D CRT Radar display ([tower_radar.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_radar.gd)), guiding field engineers via proximity radio static, firing 45m remote sector floodlights ([tower_console_button.gd](file:///home/cem/Desktop/Nosignal/src/scripts/tower_console_button.gd)), and solving signal frequency wavelength puzzles ([signal_decoder.gd](file:///home/cem/Desktop/Nosignal/src/scripts/signal_decoder.gd)).
- **Field Engineers / Investigators (1-3 Players):** Venture into the pitch-black forest storm from the outer gate (-110m, 110m), search cabins for **Electrical Fuse Kits** ([fuse_pickup.gd](file:///home/cem/Desktop/Nosignal/src/scripts/fuse_pickup.gd)), locate procedurally selected damaged antenna arrays ([antenna_panel.gd](file:///home/cem/Desktop/Nosignal/src/scripts/antenna_panel.gd)), repair panels while managing flashlight batteries, and dodge active Anomaly patrols ([anomaly_threat.gd](file:///home/cem/Desktop/Nosignal/src/scripts/anomaly_threat.gd)).

- **Elevator Pitch:** *"Voices of the Void's atmospheric signal research tension meets Lethal Company and Phasmophobia's asymmetric co-op, diegetic radio communication, and PSX fog horror."*
- **Core Verb (Ana Eylem):** *Sinyal Çözmek, Yönlendirmek, Sigorta Bulmak, Anten Tamir Etmek & Hayatta Kalmak.*

---

## 2. Core Pillars & Anti-Pillars

### 🏛️ Core Pillars

1. **Pillar 1: Spatial Audio & Radio Suspense**
   - *Design Test:* Every sound and radio signal must keep players questioning: *"Is that static coming from an antenna, my teammate's walkie-talkie, or an anomaly stalking in the dark fog?"*
2. **Pillar 2: Asymmetric Dependency & Diegetic Operations**
   - *Design Test:* The Tower Operator cannot fix antennas in the dark forest; Field Engineers cannot locate damaged sectors without the CRT Radar or survive without operator floodlight support.
3. **Pillar 3: Retro PSX Aesthetics & Volumetric Tension**
   - *Design Test:* Pixelated dither shaders, pitch-black fog, and dynamic spotlight cones create claustrophobic dread without requiring heavy AAA asset budgets.

### ⛔ Anti-Pillars

- **No Heavy Gunplay / Military Combat:** Players cannot kill anomalies with heavy firearms. Survival requires stealth (crouching + turning off flashlights), floodlight protection, and fleeing.
- **No Overly Complex CLI Code:** Terminal interactions use intuitive CRT displays, physical buttons, and frequency sliders (`A`/`D` mini-games) rather than complex command line typing.

---

## 3. MDA Framework & Core Loop

- **Mechanics:** Flashlight battery drain (125s), Fuse Kit pickups, hold-E repair progress (1.5s), 3D CRT radar blips, 4-sector remote floodlight controls (12s active, 10s cooldown), frequency slider mini-game, anomaly stealth sensing.
- **Dynamics:** Radio static intensity rising with threat proximity, panic when flashlight flickers under 20% battery, coordinating floodlight bursts to save field engineers.
- **Aesthetics:** Sensation (Grounded 3D movement), Challenge (Procedural shift initializers), Discovery (Cosmic audio log cassettes), Fellowship (Asymmetric teamwork).

### 🔄 Gameplay Loops

```
[30-Second Loop]  --->  [5-Minute Loop]   --->  [Session Shift Loop]  --->  [Meta Progression]
 (Forest navigation,     (Find Fuse Kit,         (Repair 3 antennas,         (Earn Credits $,
  flashlight battery,     repair antenna,         pull main switch,           upgrade gear at
  stealth crouching)      dodge anomaly)          decode signal & extract)    tower shop)
```

---

## 4. Player Roles & Co-Op Dynamics (Up to 4 Players)

| Role | Title | Core Responsibility | Primary Tools |
| :--- | :--- | :--- | :--- |
| **Role 1** | **Station Commander (Operator)** | Operates CRT Radar screen, fires sector floodlights, unlocks main power switch, decodes frequencies. | CRT Radar Monitor, Remote 4-Button Console, Wavelength Decoder |
| **Role 2** | **Field Engineer** | Locates Electrical Fuse Kits in forest cabins, repairs damaged antenna panels. | Electrical Fuse Kits, Maintenance Tool |
| **Role 3** | **Scout / Navigator** | Follows phosphor wire lines, tracks beacon light, guides team through 300m² fog sectors. | High-power Flashlight, Compass |
| **Role 4** | **Anomaly Specialist** | Monitors radio static warnings, alerts team of anomaly patrol presence, manages team stealth. | Radio Static Sensor, Signal Scanner |

---

## 5. Technical Architecture Summary

- **Engine:** Godot Engine 4.7.1 (`Forward+` Renderer).
- **Netcode:** Host-as-server listen model using ENet for current testing, `MultiplayerSpawner.spawn(data)` for deterministic players, and `MultiplayerSynchronizer` for replicated state. An optional Steam peer adapter exists; Steam lobby/relay integration remains planned.
- **RPC Communication:** Reliable RPCs use an intent/validation/apply flow: player-owned flashlight state uses `apply_flashlight_state`, while console and sector-light requests are validated by the host before authoritative state is applied.
- **World Map:** 300m x 300m 4-Sector Forest Map (`main.tscn`) + Central Observatory Tower.

---

## 6. Implementation Status & Roadmap

- [x] **v0.1.0 MVP:** FPS controller, hold-E repair, anomaly AI, extraction loop, power switch.
- [x] **v0.2.0 Expanded Prototype (Current):** 300m² 4-Sector forest, outer gate spawn, fuse kit pickup requirement, 3D CRT radar monitor, wavelength frequency decoder UI, remote 4-button sector floodlight console, ENet multiplayer networking.
- [ ] **Phase 4 Roadmap:** Heavy breathing / sanity meter (>8s crouching in black), twig rustling physics, 3D spatial audio engine.
- [ ] **Phase 5 Roadmap:** Multi-night shift progression (Day 1 -> Day 3), credit rewards ($), tower equipment shop (`TowerShop.tscn`).
