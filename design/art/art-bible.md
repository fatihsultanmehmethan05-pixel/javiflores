# 🎨 Art Bible: Signal Array 04

> **Version:** 1.0  
> **Status:** APPROVED  
> **Target Aesthetic:** Retro PSX Low-Poly 3D / Analog Horror  
> **Engine:** Godot Engine 4.x (Forward+ / Mobile Renderer)  

---

## 1. Visual Identity Statement

### 👁️ One-Line Visual Rule
> *"90'ların analog retro teknolojisi ile zifiri karanlık ormanın hacimsel sisi (volumetric fog) arasındaki yüksek kontrast."*

### 📐 Supporting Visual Principles

1. **Principle 1: Low-Poly + High-Atmosphere (Düşük Poligon, Yüksek Atmosfer)**
   - *Design Test:* Modellere ekstra poligon eklemek yerine piksel shader, hacimsel sis ve dinamik gölgeler ile atmosfer güçlendirilmelidir.
2. **Principle 2: Light & Shadow Hierarchy (Işık ve Gölge Hiyerarşisi)**
   - *Design Test:* Zifiri karanlık varsayılan durumdur. Sadece el feneri, CRT monitör pırıltısı ve kule ışıldakları oyuncuya güvenli alan çizer.
3. **Principle 3: CRT & Analog Artifacts (CRT ve Analog Dokusu)**
   - *Design Test:* Her teknolojik ekran ve kamera görüntüsü CRT dither, VHS çizikleri ve analog tarama çizgileri (scanlines) barındırmalıdır.

---

## 2. Mood & Atmosphere

| Oyun Durumu | Ana Duygu | Işık Karakteri | Atmosferik Sıfatlar |
| :--- | :--- | :--- | :--- |
| **Kule İçi (Observatory)** | Güvenli ama Tekinsiz | Sıcak Kehribar (#FFB000) & Yeşil CRT pırıltısı, Yüksek Kontrast | Klostrofobik, Analitik, Nostaljik |
| **Orman (Dense Forest)** | İzolasyon & Tehdit | Soğuk Mavi/Gri Sis, El fenerinin dar beyaz ışık konisi | Zifiri Karanlık, İzolasyon, Tehditkar |
| **Anomali Varlığı (Entity)** | Dehşet & Panik | Yanıp sönen kırmızı flaşörler, CRT ekran dither paraziti | Glitchli, Titrek, Rahatsız Edici |

---

## 3. Shape Language

- **Teknoloji & Kule:** Köşeli, kaba 90'lar kutu formları (Kutu CRT monitörler, kalın kablolar, ağır şalterler).
- **Çevre & Doğa:** Dik, sivri çam ağaçları, kaba organik kaya kütleleri.
- **Anomaliler / Yaratıklar:** Siluet odaklı. İnsanı andıran ama uzuvları uzamış (elongated/slender), yüz hatları belirsiz pürüzsüz gölgeler.

---

## 4. Color System

### 🎨 Renk Paleti

- **Deep Obsidian (`#0B0D10`):** Gece ormanının varsayılan karanlık rengi.
- **Fog Grey (`#2F353D`):** Hacimsel sis ve karanlık arka plan rengi.
- **CRT Amber (`#FFB000`):** Kule terminali ve standby ekranı rengi.
- **Phosphor Green (`#00FF66`):** Kilitli sinyal ve güvenlik onay renkleri.
- **Distress Crimson (`#D92B2B`):** Anomali uyarısı ve tehlike sinyali rengi.

### ♿ Renk Körlüğü Güvenliği
Kırmızı tehlike sinyalleri sadece renkle değil; **yanıp sönen flaşör ışıkları** ve **telsiz alarm sesi** ile desteklenir.

---

## 5. Character Design Direction

- **Oyuncular:** Sarı/Turuncu koruyucu yağmurluklar, kalın gaz maskeleri. Sırtlarında telsiz ünitesi ve el feneri.
- **Anomaliler:** Doğrudan insan yüzü çizilmeyecek. Gölge benzeri siluetler, ışık vurunca hafif dither/glitch yapan varlıklar.

---

## 6. Environment Design Language

- **Kule & Kulübe:** 1990'lar soğuk savaş sonrası telsiz istasyonu (brütalist beton taban + ahşap gözetleme kulesi).
- **Orman:** Yoğun çam ağaçları, toprağa gömülü kalın fosforlu sinyal kabloları, yosunlu kayalar.

---

## 7. UI/HUD Visual Direction

- **Diegetic UI:** Ekran üzerinde 2D HUD kalabalığı tutulmaz. Tüm sağlık, pil ve sinyal bilgileri oyuncunun elindeki telsiz, el feneri ve kuledeki CRT monitörler üzerindedir.

---

## 8. Asset Standards (Godot 4 & Solo Dev)

| Varlık Türü | Dokut/Texture Boyutu | Poligon / Mesh Bütçesi | Format |
| :--- | :--- | :--- | :--- |
| **Oyuncu / Yaratık** | 512x512 veya 1024x1024 | < 3,000 Poligon | `.glb` / `.gltf` |
| **Kule & Binalar** | 1024x1024 (Palette) | < 8,000 Poligon | `.tscn` / `.glb` |
| **Ağaç & Prop** | 512x512 | < 500 Poligon | `.glb` |
| **Ses Dosyaları** | 44.1kHz 16-bit | Mono (3D Spatial) / Stereo (Music) | `.wav` / `.ogg` |

---

## 9. Reference Direction & Style Prohibitions

### 📚 İlhamsal Kaynaklar (References)
- **Voices of the Void:** CRT monitör dili ve kule izolasyonu.
- **Iron Lung:** Klostrofobi ve analog göstergeler.
- **Slender: The Arrival:** Açık orman gerilimi ve siluet yaratıklar.
- **Pacific Drive:** Retro anomali ve telsiz atmosferi.

### ⛔ Yasaklar (Prohibitions)
- PBR yüksek parlaklıklı kaplamalar **KULLANILMAYACAK**.
- Aşırı detaylı gerçekçi insan yüzleri **ÇİZİLMEYECEK**.
- Neon / Cyberpunk parlak renkler **EKLENMEYECEK**.
