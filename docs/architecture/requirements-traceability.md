# Requirements Traceability Matrix — Signal Array 04

> **Version:** 1.0
> **Last Updated:** 2026-08-11
> **Engine:** Godot Engine 4.7.1
> **Design Traceability:** 23 / 23 requirements have an intended architectural owner.
> **Behavioral Implementation:** Partial; statuses below distinguish Verified, Partial, and Planned.

---

## 1. Traceability Table

| Req ID | Source GDD | Description | Layer | Architectural Module | Governing ADR | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `TR-player-001` | `player-controller-fps` | Grounded 3D FPS kinematics | Core | `Player` (`player.gd`) | Engine Standard | ✅ Covered |
| `TR-player-002` | `player-controller-fps` | Dynamic capsule height (1.8m $\to$ 1.1m) | Core | `Player` (`player.gd`) | Engine Standard | ✅ Covered |
| `TR-player-003` | `player-controller-fps` | Central 3.5m `InteractRayCast` | Core | `Player` (`player.gd`) | Engine Standard | ✅ Covered |
| `TR-netcode-001` | `multiplayer-netcode-system` | Host-as-Server P2P Listen Server | Foundation | `NetworkManager` (`network_manager.gd`) | **ADR-001** | ✅ Covered |
| `TR-netcode-002` | `multiplayer-netcode-system` | Dynamic peer authority spawning | Foundation | `NetworkManager` (`network_manager.gd`) | **ADR-001** | ✅ Covered |
| `TR-netcode-003` | `multiplayer-netcode-system` | Reliable RPC state synchronization | Foundation | `NetworkManager`, `Flashlight` | **ADR-001** | ✅ Covered |
| `TR-flashlight-001` | `flashlight-power-system` | Battery depletion & flicker effect | Core | `Flashlight` (`flashlight.gd`) | Engine Standard | ✅ Covered |
| `TR-flashlight-002` | `flashlight-power-system` | Active beam stealth exposure | Core | `Flashlight`, `AnomalyThreat` | Engine Standard | ✅ Covered |
| `TR-antennae-001` | `forest-antennae-system` | Procedural shift initializer (3/8) | Feature | `ForestAntennaManager` | Engine Standard | ✅ Covered |
| `TR-antennae-002` | `forest-antennae-system` | Fuse Kit pickup & hold-E repair | Feature | `AntennaPanel`, `FusePickup` | Engine Standard | 🟡 Partial |
| `TR-terminal-001` | `tower-terminal-system` | 3D CRT Radar monitor | Feature | `TowerRadar` (`tower_radar.gd`) | Engine Standard | ✅ Covered |
| `TR-terminal-002` | `tower-terminal-system` | Remote 4-button floodlight console | Feature | `TowerConsoleButton`, `SectorFloodlight` | **ADR-001** | ✅ Covered |
| `TR-terminal-003` | `tower-terminal-system` | Main power switch lockdown | Feature | `TowerSwitch` (`tower_switch.gd`) | Engine Standard | ✅ Covered |
| `TR-terminal-004` | `tower-terminal-system` | Wavelength frequency decoder UI | Feature | `SignalDecoder` (`signal_decoder.gd`) | Engine Standard | 🟡 Partial (local decoder; authoritative multiplayer result planned) |
| `TR-anomaly-001` | `anomaly-entity-ai` | Area3D patrol/chase state machine | Feature | `AnomalyThreat` (`anomaly_threat.gd`) | Engine Standard | 🟡 Partial (multiplayer targeting and balance pending) |
| `TR-anomaly-002` | `anomaly-entity-ai` | Stealth detection sensor | Feature | `AnomalyThreat` (`anomaly_threat.gd`) | Engine Standard | ✅ Covered |
| `TR-anomaly-003` | `anomaly-entity-ai` | Safe zone disengagement | Feature | `AnomalyThreat`, `MainGame` | Engine Standard | ✅ Covered |
| `TR-ui-001` | `diegetic-ui-system` | Diegetic HUD prompts and status bars | Presentation | `HUD` (`hud.gd`) | Engine Standard | 🟡 Partial (team outcome and polish pending) |
| `TR-ui-002` | `diegetic-ui-system` | Multiplayer Lobby UI overlay | Presentation | `LobbyUI` (`lobby_ui.gd`) | **ADR-001** | ✅ Covered |
| `TR-radio-001` | `radio-communication-system` | Distance radio static & beeping | Core | `MainGame`, `HUD` | **ADR-002** | 🟡 Partial (HUD text only; audio planned) |
| `TR-save-001` | `save-progression-system` | Multi-night shift credit rewards | Foundation | `SaveProgressionSystem`, `MainGame` | **ADR-003** | ⚪ Planned |
| `TR-save-002` | `save-progression-system` | Tower Supply Shop equipment | Foundation | `TowerShop`, `Flashlight` | **ADR-003** | ⚪ Planned |
| `TR-save-003` | `save-progression-system` | JSON save data serialization | Foundation | `SaveProgressionSystem` | **ADR-003** | ⚪ Planned |
