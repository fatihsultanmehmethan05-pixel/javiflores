# Signal Array 04

A retro low-poly first-person co-op horror game set around an isolated signal observatory and a storm-covered forest. Players recover fuse kits, repair damaged antenna arrays, coordinate tower floodlights, avoid an anomaly, and decode a signal before extraction.

> **Engine:** Godot Engine 4.7.1 (`Forward+`)
> **Platform:** PC / Steam target
> **Current stage:** Multiplayer vertical-slice stabilization
> **Current transport:** ENet listen server (LAN/direct IP)
> **Planned transport:** Steam lobby, invite, and relay P2P

- [Architecture decision](design/architecture/adr-001-listen-server-multiplayer.md)
- [Implementation roadmap](docs/implementation_guide.md)
- [Current implementation review](design/gdd/gdd-implementation-alignment-2026-08-11.md)
- [Systems index](design/gdd/systems-index.md)

## Current Build

The repository contains a playable multiplayer prototype with:

- An FPS controller with sprint, crouch, mouse look, head bob, and interaction raycast.
- A 300 m × 300 m forest divided into North, East, South, and West sectors.
- Eight candidate antenna sites, with three selected as damaged for a shift.
- Fuse pickup and hold-to-repair interactions.
- Flashlight battery drain, low-battery flicker, and replicated on/off state.
- A tower radar, four-sector floodlight console, main switch, and frequency decoder.
- Prototype anomaly patrol, chase, stealth detection, and safe-zone behavior.
- ENet host/join flow, network player spawning, peer-owned local input/camera, and replicated player state.

This is an early vertical slice, not a production-ready multiplayer build.

## Known Gaps

- Objectives, decoder results, anomaly behavior, and team outcome still need one consistently host-authoritative session state.
- Disconnect/reconnect, host loss, late join, packet loss, and four-player soak behavior need automated regression coverage.
- Steam transport is adapter scaffolding only; GodotSteam binaries, lobbies, invites, relay, and packaging are not integrated.
- Radio proximity currently uses HUD feedback; spatial radio audio, footsteps, interference audio, and voice are planned.
- Save files, credits, multi-night progression, and the tower shop are designed but not implemented.
- Repair interruption/decay feedback, anomaly target selection, floodlight gameplay effect, and overall balance require further work.

## Controls

| Input | Action |
| :--- | :--- |
| `W A S D` | Move; tune frequency while the decoder is open |
| `Left Shift` | Sprint |
| `Left Ctrl` | Crouch |
| `F` | Toggle flashlight |
| `E` / hold `E` | Interact, collect fuse, repair, use switch or console |
| `Esc` | Close UI or toggle mouse capture |
| `R` | Restart after victory or game over |

## Multiplayer Model

The current build uses a host-as-server listen model. The host runs the authoritative ENet peer and also participates as a player. Each spawned player keeps local ownership of its own input and camera. Gameplay interactions are being migrated to a client-intent → host-validation → authoritative-apply flow.

For current testing, use LAN or a reachable direct IP. Internet play may require router configuration. Steam relay is roadmap work and should not yet be treated as available.

## Roadmap

Roadmap scope remains open for evaluation; unchecked items are plans, not implementation claims.

### Phase 3 — Multiplayer Networking and Dynamic Role Scaling

- [x] ENet listen-server foundation and host/join lobby.
- [x] Deterministic peer-named player spawning and local input/camera ownership.
- [x] `MultiplayerSpawner` and `MultiplayerSynchronizer` replication foundation.
- [ ] Authoritative objective, decoder, anomaly, and team-outcome state.
- [ ] Disconnect/reconnect, host-loss, late-join, stress, and network-conditioning test harness.
- [ ] Steam lobby, invites, relay transport, adapter integration, and shipping validation.
- [ ] Mechanically distinct operator/field roles and player-count scaling.

### Phase 4 — Sanity, Weather, and Atmospheric Audio Polish

- [ ] Heavy breathing / sanity pressure while hiding in darkness.
- [ ] Bush and twig rustle interactions that can alert anomalies.
- [ ] Surface footsteps, storm acoustics, spatial radio interference, and positional communication.
- [ ] Dense fog, electromagnetic storm, and blood-moon shift mutators.

### Phase 5 — Shift Economy and Tower Equipment Shop

- [ ] Day 1 → Day 3 shift progression and difficulty scaling.
- [ ] Credit rewards based on signal quality and extraction outcome.
- [ ] Tower shop with batteries, motion sensors, flare tools, and radio upgrades.
- [ ] Versioned atomic save/load and ownership rules for co-op progression.
- [ ] Economy, replenishment, repeatable sinks, and dominant-strategy validation.

## Run Locally

1. Clone the repository:

   ```bash
   git clone https://github.com/javiflores/signal_array.git
   cd signal_array
   ```

2. Open `project.godot` with Godot 4.7.1.
3. Run the project with `F5`.
4. In the lobby, create a host in one instance and join its address from the other instances.

For multi-instance testing, use separate game processes. The project does not yet include an automated headless multiplayer harness.

## Repository Layout

```text
design/
  architecture/    Architecture decisions
  art/             Art direction
  gdd/             Game and system design documents
  registry/        Shared entity/formula registry
docs/
  architecture/    Master architecture, controls, traceability
  implementation_guide.md
production/         Gate and active-stage records
src/
  scenes/           Godot scenes
  scripts/          GDScript gameplay and networking code
project.godot
```

## Documentation Status

Design documents distinguish implemented prototype behavior from partial and planned work. Historical PASS reports remain archived and are explicitly marked as superseded where later source review found implementation gaps.
