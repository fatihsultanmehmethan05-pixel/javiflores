# GDD and Implementation Alignment Review — 2026-08-11

> **Verdict:** FAIL for production readiness; playable multiplayer prototype / early vertical slice.
> **Scope:** Current implementation truth, cross-GDD consistency, architecture alignment, and roadmap separation.
> **Roadmap policy:** Existing future phases are preserved for later evaluation. No roadmap item was removed, promoted, or rescheduled by this review.

## Current Build

The repository contains a playable Godot 4.7.1 multiplayer prototype with FPS movement, flashlight and battery behavior, fuse pickup and antenna repair, tower interactions, a local frequency decoder, anomaly behavior, HUD/lobby flows, and an ENet listen-server path. Recent authority fixes keep local camera and input ownership tied to the correct peer.

Steam transport is adapter scaffolding only. GodotSteam binaries, Steam lobby/invite flow, relay transport, and shipping integration are not implemented. Direct ENet currently means LAN/direct IP and may require router configuration.

## Implementation Status

| Area | Current status | Remaining evaluation/work |
| :--- | :--- | :--- |
| Player controller | Implemented prototype | Multiplayer movement validation, interpolation, collider isolation |
| ENet multiplayer | Implemented prototype | Authoritative world/game state, lifecycle cleanup, repeatable stress tests |
| Steam P2P | Planned | Lobby, invites, relay, adapter integration, packaging |
| Flashlight | Implemented prototype | Authority hardening and remote visual consistency |
| Antenna/fuse loop | Partial | Repair decay, damage interruption, explicit prompts, convergence |
| Tower/decoder | Partial | One authoritative decoder target/progress/result and team state |
| Anomaly AI | Partial | Closest exposed-player selection, server ownership, balance |
| HUD/lobby | Partial | Failure recovery, team outcome, UX polish |
| Radio | Partial, HUD cues only | Spatial audio, voice path, audio routing |
| Save/progression/shop | Designed, not implemented | Entire Phase 5 implementation and economy validation |
| Automated multiplayer QA | Not established | Harness, metrics, packet conditioning, soak/churn/late-join tests |

## Blocking Findings

1. Objective, decoder, AI, and team-outcome state are not yet consistently host-authoritative. Late join and concurrent interactions can diverge.
2. Save, credits, shop, multi-night progression, and JSON persistence exist in design only. Earlier claims that these were implemented were incorrect and have been downgraded.
3. Radio functionality currently renders textual proximity cues; spatial sound, footsteps, interference audio, and voice are roadmap work.
4. Repair decay and damage interruption described by the GDD are incomplete, and missing-fuse/standing feedback does not fully meet the target contract.
5. Anomaly movement and floodlight behavior do not yet support the intended stealth/cooperative pressure reliably.
6. The repository has no executable multiplayer stress harness or measurable performance/network acceptance gate.

## Design Risks to Evaluate

- The anomaly is slower than normal walking, making retreat dominate stealth.
- Floodlight active duration exceeds its cooldown and currently has no meaningful AI effect.
- Peak forest play can demand navigation, battery, stealth, threat reading, repair inventory, and communication simultaneously.
- The planned economy has finite upgrade sinks and a potentially dominant early battery purchase.
- Team-wipe, downed/spectator behavior, item replenishment, role ownership, and player-count scaling require explicit decisions.

## Recommended Priority

- **P0:** Authoritative session/objective/decoder/team outcome and disconnect/late-join correctness.
- **P1:** Multiplayer regression/stress harness; anomaly targeting and balance; repair interruption/feedback; floodlight gameplay effect.
- **P2:** Steam transport integration and radio audio/voice according to the existing roadmap.
- **P3:** Evaluate and implement the existing save/progression/shop roadmap after the core loop and multiplayer state are stable.

## Documentation Changes

System GDD headers and implementation notes, systems index, architecture, ADR status, control manifest, requirements traceability, implementation guide, README, entity registry, gate history, and active session state now distinguish implemented prototype behavior from partial and planned work. The original roadmap remains the planning baseline.
