# Steam P2P Listen-Server Setup

Signal Array 04 uses one gameplay architecture with interchangeable `MultiplayerPeer`
transports:

- ENet is the local/LAN development transport.
- GodotSteam `SteamMultiplayerPeer` is the production Steam transport.
- Peer ID 1 is always the authoritative listen server and also controls the host player.
- Steam lobby owner is the host Steam ID. All gameplay traffic routes through that host.

## Required external components

The repository intentionally does not bundle proprietary Steamworks binaries.

1. Add a Godot 4.7-compatible GodotSteam GDExtension.
2. Add the matching GodotSteam MultiplayerPeer extension exposing
   `SteamMultiplayerPeer`.
3. Add the Steamworks redistributables required by the target platform.
4. Set the real Steam App ID for release builds. Use App ID 480 only for local development.
5. Initialize Steam and call relay-network initialization before opening the multiplayer
   lobby.

References:

- Steam networking overview: https://partner.steamgames.com/doc/features/multiplayer/networking
- Steam Networking Sockets: https://partner.steamgames.com/doc/api/ISteamNetworkingSockets
- GodotSteam: https://godotsteam.com/

## Lobby flow

1. Host creates a Steam lobby with four member slots.
2. Host stores the selected role/session metadata in lobby data.
3. After lobby creation, call:
   `network_manager.create_steam_host(0)`
4. Joining players obtain the lobby owner Steam ID and call:
   `network_manager.join_steam_host(lobby_owner_steam_id, 0)`
5. Do not pass public IP addresses through Steam. The MultiplayerPeer uses the Steam ID and
   Steam Datagram Relay.
6. If the host leaves, return every client to the lobby. Host migration is not implemented
   by ADR-001.

## Authority contract

- Clients send intent to peer 1.
- Peer 1 validates sender, distance, inventory, cooldown and current game phase.
- Only peer 1 broadcasts world-state results.
- Each player peer owns only its movement/camera/flashlight presentation.
- Procedural antenna selection and anomaly AI run on peer 1.
- Static gameplay RPC paths must remain identical on every peer.

## Release validation

Before shipping, repeat the automated four-peer regression with Steam accounts on separate
machines, then test:

- lobby full/rejection behavior;
- host disconnect and lobby restoration;
- Steam invite and lobby-owner lookup;
- late join world-state snapshot;
- 100/250/500 ms latency profiles;
- 1% and 5% packet loss;
- relay-only connectivity without port forwarding.
