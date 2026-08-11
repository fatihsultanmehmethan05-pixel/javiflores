# 🗺️ Systems Index: Signal Array 04

> **Version:** 0.2.0
> **Game Concept:** [Signal Array 04 Game Concept](file:///home/cem/Desktop/Nosignal/design/gdd/game-concept.md)
> **Engine:** Godot 4.7.1 (GDScript `CharacterBody3D` & `ENetMultiplayerPeer`)
> **Total Systems:** 9 Systems

---

## 1. Systems Enumeration

| System Slug | Category | Type | Status | Description |
| :--- | :--- | :--- | :--- | :--- |
| [`player-controller-fps`](file:///home/cem/Desktop/Nosignal/design/gdd/player-controller-fps.md) | Gameplay | Implicit | **Implemented (Prototype)** | 3D FPS character movement, crouching, sprint, mouse look, head bobbing, interact raycast. |
| [`multiplayer-netcode-system`](file:///home/cem/Desktop/Nosignal/design/gdd/multiplayer-netcode-system.md) | Core Architecture | Implicit | **Implemented (ENet Prototype); Steam Planned** | ENet listen server, peer authority, player spawning, RPC state synchronization. |
| [`flashlight-power-system`](file:///home/cem/Desktop/Nosignal/design/gdd/flashlight-power-system.md) | Gameplay | Implicit | **Implemented (Prototype)** | Battery depletion (125s), low battery flicker (<=20%), RPC toggle sync, light energy. |
| [`forest-antennae-system`](file:///home/cem/Desktop/Nosignal/design/gdd/forest-antennae-system.md) | Environment | Explicit | **Partially Implemented** | Procedural shift initializer (3 damaged of 8), Fuse Kit pickup requirement, hold-E repair. |
| [`tower-terminal-system`](file:///home/cem/Desktop/Nosignal/design/gdd/tower-terminal-system.md) | Gameplay / UI | Explicit | **Partially Implemented** | 3D CRT Radar monitor, remote 4-sector floodlight console, main power switch, frequency decoder UI. |
| [`anomaly-entity-ai`](file:///home/cem/Desktop/Nosignal/design/gdd/anomaly-entity-ai.md) | AI / Horror | Explicit | **Partially Implemented** | Area3D patrol/chase state machine, stealth detection (crouch + flashlight OFF), safe zone disengage. |
| [`diegetic-ui-system`](file:///home/cem/Desktop/Nosignal/design/gdd/diegetic-ui-system.md) | Presentation | Implicit | **Partially Implemented** | Diegetic HUD, prompt label, health/battery progress bars, stealth indicator, overlay screens. |
| [`radio-communication-system`](file:///home/cem/Desktop/Nosignal/design/gdd/radio-communication-system.md) | Gameplay / Audio | Explicit | **Partially Implemented** | Proximity radio static warning, frequency beeping, spatial audio & upcoming voice chat. |
| [`save-progression-system`](file:///home/cem/Desktop/Nosignal/design/gdd/save-progression-system.md) | Meta | Implicit | **Designed / Not Implemented** | Multi-night shift progression (Day 1 -> Day 3), credit rewards ($), tower shop unlocks. |

---

## 2. Dependency Graph & Layers

```
Layer 1: Foundation (Temel Mimariler)
├── multiplayer-netcode-system
└── player-controller-fps

Layer 2: Core Gameplay (Temel Oynanış)
├── radio-communication-system   (Depends on: multiplayer-netcode-system, player-controller-fps)
├── flashlight-power-system        (Depends on: player-controller-fps, multiplayer-netcode-system)
└── forest-antennae-system         (Depends on: player-controller-fps, flashlight-power-system)

Layer 3: Game Features & AI (Gelişmiş Özellikler)
├── tower-terminal-system          (Depends on: forest-antennae-system, diegetic-ui-system, multiplayer-netcode-system)
└── anomaly-entity-ai              (Depends on: radio-communication-system, player-controller-fps, flashlight-power-system)

Layer 4: Presentation (Sunum & UI)
└── diegetic-ui-system             (Depends on: player-controller-fps, tower-terminal-system)

Layer 5: Meta & Polish (Gelişim & Mağaza)
└── save-progression-system        (Depends on: tower-terminal-system, diegetic-ui-system)
```

---

## 3. Recommended Design & Implementation Order

1. **`player-controller-fps`** (Foundation — 3D Hareket, Bakış & Etkileşim)
2. **`multiplayer-netcode-system`** (Foundation — ENet Listen Server & RPC Sync)
3. **`flashlight-power-system`** (Core — Pil Tüketimi & Işık Yönetimi)
4. **`forest-antennae-system`** (Core — Orman Antenleri & Sigorta Kitleri)
5. **`radio-communication-system`** (Core — Telsiz Cızırtısı & Proximity Signals)
6. **`tower-terminal-system`** (Feature — CRT Radar, Projektör Konsolu & Sinyal Çözücü)
7. **`anomaly-entity-ai`** (Feature — Yaratık Yapay Zekası & Gizlilik Algılama)
8. **`diegetic-ui-system`** (Presentation — Dünya İçi UI & HUD)
9. **`save-progression-system`** (Meta — Gece Vardiyaları & Mağaza Yükseltmeleri)

---

## 4. High-Risk Systems & Mitigations

- 🔴 **`radio-communication-system`**: Proximity voice chat and spatial radio static sync in multiplayer.
  *Mitigation:* Native Godot 4 `AudioStreamPlayer3D` proximity bus routing + Vivox/SteamSockets extension.
- 🟡 **`anomaly-entity-ai`**: AI state fairness during terminal UI decoding.
  *Mitigation:* Safe Zone mechanism automatically disengages anomalies during `DECODING_PHASE` and `VICTORY` states.
- 🟡 **`multiplayer-netcode-system`**: Latency during physics interaction and interactive item pickup.
  *Mitigation:* Server authority (`multiplayer.is_server()`) with local client prediction for FPS movement.

---

## 5. Architectural Records (ADRs)

- [x] **ADR-001**: Peer-to-Peer Listen Server Architecture ([ADR-001](file:///home/cem/Desktop/Nosignal/design/architecture/adr-001-listen-server-multiplayer.md))
