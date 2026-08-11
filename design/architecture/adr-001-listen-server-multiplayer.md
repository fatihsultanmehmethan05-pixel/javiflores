# ADR-001: Peer-to-Peer Listen Server Architecture for Multiplayer

> **Status:** Accepted (Target Architecture; Steam transport pending)
> **Date**: 2026-08-10
> **Context**: Asymmetric 4-Player Co-Op & Solo FPS Horror (*Signal Array 04*)
> **Engine**: Godot Engine 4.7.1 (`ENetMultiplayerPeer` / `GodotSteam`)

---

## Context

*Signal Array 04* hem Tek Kişilik (Solo) hem de 4 Kişilik Asimetrik Co-Op (1 Kule Operatörü + 3 Saha Elemanı) oynanışına uygun olarak tasarlanmaktadır. Tek kişilik bir geliştirici ekibi (Solo Dev) ve PC/Steam platformu hedefi göz önüne alındığında, aylık sunucu maliyetlerini (AWS/DigitalOcean) sıfıra indirmek, sunucu bakım yükünü ortadan kaldırmak ve oyuncuların Steam üzerinden port açmadan arkadaşlarıyla lobide buluşmasını sağlamak temel bir teknik gereksinimdir.

---

## Decision

Projede **Host-as-Server (Listen Server / Peer-to-Peer)** mimarisi kullanılacaktır.

1. **Host-as-Server Yapısı:** Lobiyi kuran Oyuncu 1 (Host), Godot 4 üzerinde hem Sunucu (Server Mantığı) hem de 1. Oyuncu İstemcisi olarak çalışır.
2. **Sunucu Yetkisi (Server-Authoritative Logic):** Tüm kritik oyun durumları (Anten tamir yüzdesi, Anomali yaratık yapay zekası, oyuncu sağlığı ve görev durumu) Sunucu Yetkisi (`multiplayer.is_server()`) altında hesaplanır.
3. **Steam P2P Relay (`GodotSteam` / Steam Sockets):** Bağlantılar ve NAT geçişleri Steam Relay ağları üzerinden sağlanacaktır. Bu sayede hiçbir oyuncu modeminden port açmak zorunda kalmaz.
   - Current state: an optional `SteamNetworkAdapter` integration point exists; GodotSteam binaries, lobby/invite flow, and relay initialization are not yet integrated.
4. **Tek Kişilik Mod Uyumu:** Solo oynarken yerel oyuncu kendi sunucusu gibi çalışır. Tek kişilik mod ile 4 kişilik co-op modu **aynı kod tabanını** çalıştırır.

---

## Consequences

### Olumlu Sonuçlar (Positive):
- **$0 Sunucu Maliyeti:** Aylık hiçbir kiralık sunucu faturası ödenmez.
- **Sıfır Sunucu Bakımı:** Sunucu çökmesi veya bakımı gibi sorunlar yaşanmaz.
- **Steam Entegrasyonu (Planned):** Steam lobby, invite, profile, and relay behavior becomes available after the GodotSteam integration is completed.
- **Kod Bütünlüğü:** Solo ve Co-Op için 2 ayrı kod yazılmaz; tek bir modüler altyapı kullanılır.

### Dikkat Edilecek Hususlar (Negative / Mitigations):
- Oyunu kuran Host'un bağlantısı koptuğunda oda kapanır (Host Migration veya lobiye dönme gerekebilir).
- Anomali yapay zekası ve fizik hesaplamaları Host'un işlemcisinde çalışacağı için Host bilgisayarının işlemci yükü diğer katılımcılara göre biraz daha fazla olur.
