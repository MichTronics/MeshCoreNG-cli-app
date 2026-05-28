# MeshCLI NG — Handleiding

> 🇬🇧 English version: [README.md](../README.md) · 🇩🇪 Deutsche Version: [ANLEITUNG.md](ANLEITUNG.md)

Een Flutter-console-app voor MeshCoreNG-repeaters en companion-radio's.  
Verbind via **USB-serieel**, **BLE** of **TCP** en stuur CLI-commando's naar je mesh-knooppunt — op Android, Linux en Windows.

---

## Wat doet de app?

MeshCLI NG geeft je een terminalvenster voor MeshCoreNG-apparaten in drie modi:

| Modus | Verbinding met | Transport |
|---|---|---|
| **Companion** | Een companion-radio met MeshCore companion-firmware | BLE · USB · TCP |
| **Repeater Remote** | Een verre repeater bereikt via de companion over het mesh | (via companion) |
| **Repeater Serieel** | Een repeater direct via USB-serieel | USB-serieel |

De app heeft geen chat-interface en geen contactenlijst — het is een compacte CLI-console. In de directe serieel-modus zit ook een interactief **configuratiepaneel** waarmee je alle instellingen van je repeater kunt ophalen, aanpassen en terugsturen.

---

## Ondersteunde platformen

| Platform | USB-serieel | BLE | TCP |
|---|---|---|---|
| Android | ✅ | ✅ | ✅ |
| Linux | ✅ | — | ✅ |
| Windows | ✅ | — | ✅ |

BLE op desktop is niet opgenomen; gebruik serieel of TCP op Linux/Windows.

### Android USB / OTG

Voor USB-serieel op Android moet de telefoon **USB OTG / USB-host** ondersteunen.
Dat is nodig omdat de MeshCore-node rechtstreeks aan de telefoon hangt: de telefoon moet dan de USB-host zijn en de app toestemming geven om de seriële poort te openen.

Gebruik:
- een USB-C OTG-adapter of USB-C datakabel
- een MeshCore-node/repeater die als USB-seriële poort verschijnt
- de Android USB-toestemming die verschijnt bij scannen of verbinden

Wanneer je een ondersteunde USB-seriële node aansluit, hoort Android **MeshCLI NG** aan te bieden als app voor dat USB-apparaat. Gebeurt dat niet, installeer dan de nieuwste APK, trek de node los en sluit hem opnieuw aan, en controleer of de kabel echt data/OTG ondersteunt.

Heeft je telefoon geen OTG of werkt de kabel alleen voor laden, gebruik dan **BLE** of **TCP**.

---

## Installatie en starten

### Vereisten

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versie 3.24 of hoger
- Android: Android SDK + een aangesloten telefoon of emulator
- Linux: `libserialport` (`sudo apt install libserialport-dev`)
- Windows: Visual Studio met **Desktop development with C++**

```sh
# Afhankelijkheden installeren
flutter pub get

# Android
flutter run -d android

# Linux desktop
flutter run -d linux

# Windows desktop
flutter run -d windows
```

---

## Gebruik

### Modus 1 — Companion

Verbindt met een companion-radio (het apparaat dat je bij je draagt) via BLE, USB of TCP.

**Stappen:**
1. Kies het transporttabblad: **USB**, **BLE** of **TCP**
2. Druk op **Scan** om beschikbare apparaten te zoeken
3. Selecteer je apparaat uit de lijst → de app verbindt automatisch
4. Typ een commando in het invoerveld en druk op **Send** of Enter

Bij het verbinden vraagt de app automatisch de apparaatinfo op en toont:
```
Connected! Device: MijnNode  version 1.0.0-80abfbb  freq: 869.6180 MHz
```

**Beschikbare commando's** (type `help` voor de volledige lijst):

| Commando | Omschrijving |
|---|---|
| `info` | Apparaatnaam, firmware-versie, radio-instellingen, batterij |
| `ver` | Alleen firmware-versie |
| `nodes` | Lijst van bekende contacten / buren |
| `clock` | Apparaattijd |
| `bat` | Batterijspanning en opslagruimte |
| `stats [core\|radio\|packets]` | Statistieken |
| `reboot` | Apparaat herstarten |
| `get <param>` | Instelling opvragen (zie tabel) |
| `set <param> <waarde>` | Instelling wijzigen (zie tabel) |

**get / set parameters:**

| Parameter | Omschrijving | Voorbeeld |
|---|---|---|
| `name` | Naam van het knooppunt | `set name MijnRepeater` |
| `freq` | Radiofrequentie (MHz) | `set freq 869.5` |
| `bw` | Bandbreedte (kHz) | `set bw 250` |
| `sf` | Spreading factor | `set sf 10` |
| `cr` | Coderingsverhouding | `set cr 5` |
| `tx` | Zendvermogen (dBm) | `set tx 20` |
| `repeat` | Pakketdoorschakeling aan/uit | `set repeat on` |
| `public.key` | Publieke sleutel van het knooppunt | (alleen lezen) |
| `firmware` | Firmware-versie | (alleen lezen) |
| `battery` | Batterijspanning | (alleen lezen) |
| `time` | Apparaatklok | (via `clock`) |

---

### Modus 2 — Repeater Remote

Stuurt CLI-commando's naar een **verre repeater** via het mesh-netwerk, doorgegeven door je companion-radio.

**Stappen:**
1. Klik op het tabblad **Repeater Remote**
2. Verbind eerst je companion-radio (zie hierboven)
3. Plak de **publieke sleutel** van de verre repeater in het sleutelveld (of de eerste paar hex-bytes als prefix)
4. Typ een firmware-CLI-commando en druk op **Send**

Het commando wordt via het mesh afgeleverd en de reactie verschijnt in de console.  
Type `help` voor de volledige lijst van ondersteunde Repeater Remote-commando's.

---

### Modus 3 — Repeater Serieel

Verbindt rechtstreeks met een **repeater via USB-serieel**, zonder tussenkomst van een companion-radio.  
Dit is gelijkwaardig aan `meshcore-cli -r -s /dev/ttyACM0`.

**Stappen:**
1. Klik op het tabblad **Repeater Serieel**
2. Druk op **Scan** om de beschikbare seriële poorten te zoeken
3. Selecteer de poort van je repeater
4. De app verbindt, vraagt de apparaatnaam en firmware-versie op, en toont:

```
INFO:meshcore:Connecting to repeater at /dev/ttyACM0 (115200 baud)...
Connected! Device: GWNL-Bridge-Bovenkarspel version 1.0.0-80abfbb (Build: 17-May-2026)
Type help for commands, quit to exit, Tab for completion
--------------------------------------------------
GWNL-Bridge-Bovenkarspel> get freq
  -> > 869.6179809
GWNL-Bridge-Bovenkarspel> set repeat on
  -> > OK
```

Elk commando dat je typt wordt weergegeven met de apparaatnaam als prompt.  
Echo-regels en lege prompts van het apparaat worden automatisch weggefilterd.

Type `help` om alle beschikbare firmware-commando's te zien.  
`clock sync` is een speciaal commando dat de huidige pc-tijd naar het apparaat stuurt.

**Belangrijkste firmware-commando's (serieel):**

| Categorie | Commando's |
|---|---|
| Info | `ver` · `board` · `clock` · `clock sync` |
| Radio | `get radio` → freq, bw, sf, cr · `set freq <MHz>` · `set bw <kHz>` · `set sf <n>` · `set cr <n>` · `set tx <dBm>` |
| Netwerk | `advert` · `advert.zerohop` · `discover.neighbors` · `neighbors` |
| Statistieken | `stats-core` · `stats-radio` · `stats-packets` · `clear stats` |
| Logging | `log start` · `log stop` · `log` · `log erase` |
| Sensoren | `sensor get <sleutel>` · `sensor set <sleutel> <waarde>` · `sensor list` |
| GPS | `gps` · `gps on\|off` · `gps sync` · `gps setloc` · `gps advert` |
| Regio's | `region` · `region list` · `region get/put/remove` · `regiondb find` · … |
| Energie | `powersaving on\|off` · `reboot` · `poweroff` · `start ota` |
| Toegang | `get acl` · `setperm <pubkey> <rechten>` · `password <wachtwoord>` |
| TCP-brug | `get wifi.status` → WiFi-status, IP-adres, RSSI, serververbinding |

> **Let op:** `get radio` geeft `freq,bw,sf,cr` terug als één kommagescheiden waarde. De firmware heeft geen afzonderlijke `get sf`, `get bw` of `get cr` commando's — gebruik `set sf <n>` e.d. om ze individueel aan te passen.

#### Configuratiepaneel

Zodra je verbonden bent verschijnt de knop **Config** in de werkbalk. Klik erop — of typ `config` in het invoerveld — om een interactief paneel te openen dat:

- Alle instelbare parameters ophaalt van het apparaat (gegroepeerd per categorie)
- De huidige waarden toont in bewerkbare tekstvelden en keuzelijsten
- Elk veld dat je wijzigt oranje markeert
- Bij **Apply changes** alleen de gewijzigde `set`-commando's naar het apparaat stuurt en ✓ of ✗ per parameter laat zien
- **WiFi- en brug-instellingen** herkent die een herstart vereisen: na het toepassen verschijnt een waarschuwingsbanner met een knop **Reboot now**
- Een stap **Regio's** bevat voor home/default scope, flood allow/deny-lijsten, Nederlandse locatie-lookup en een preset die `de` plus alle 16 Duitse deelstaten toevoegt
- Een lokale Nederlandse `regiondb` lookup-tabel in de app gebruikt, zodat `regiondb find <prefix>` ook werkt als de firmwaredatabase uit staat

**Parametergroepen in het configuratiepaneel:**

| Sectie | Parameters |
|---|---|
| Identity | `name` · `owner.info` · `lat` · `lon` |
| Radio | `freq` · `bw` · `sf` · `cr` · `tx` · `af` · `repeat` · `dutycycle` · `radio.rxgain` |
| Advertising | `advert.interval` · `flood.advert.interval` |
| Flood / Routing | `flood.max` · `flood.advert.base` · `flood.relay.prob` · `flood.dynamic.enable` · `path.hash.mode` · `loop.detect` · `multi.acks` · `int.thresh` · `rxdelay` · `txdelay` · `direct.txdelay` · `agc.reset.interval` |
| Access | admin-wachtwoord (`password <wachtwoord>`) · `guest.password` · `allow.read.only` |
| TCP Bridge | `bridge.enabled` · `wifi.ssid` · `wifi.password` · `bridge.server` · `bridge.port` · `bridge.delay` |
| ESPNow Bridge | `bridge.source` · `bridge.baud` · `bridge.channel` · `bridge.secret` |
| Regio's | `region home` · `region default` · `region allowf/denyf` · `region put` · `regiondb find` |

Admin-, wifi- en bridge-secretvelden zijn alleen schrijven (worden nooit van het apparaat opgehaald). Laat ze leeg om de huidige waarde ongewijzigd te laten.
Alle TCP Bridge- en ESPNow Bridge-instellingen vereisen een herstart van het apparaat voordat ze actief worden.

---

## Console-kleuren

| Kleur | Betekenis |
|---|---|
| Oranje | Commando dat jij hebt verstuurd (TX) |
| Groen | Reactie van het apparaat (RX) |
| Blauwgrijs | Info / statusberichten |
| Rood | Fout |

---

## Projectstructuur

```
lib/
├── core/
│   ├── commands/       # Getypeerde command-builders (MeshCommands)
│   ├── models/         # Verbindingsstatus, MeshNode
│   ├── packets/        # Pakkettype-enums en event-modellen
│   ├── parser/         # Binaire frame-parsers
│   ├── protocol/       # Seriële framingconstanten
│   ├── session/        # Commandowachtrij, response-matching, toestandsstreams
│   └── transport/      # BLE, USB-serieel, desktop-serieel, TCP-transporten
├── features/
│   └── console/        # Hoofdconsolescherm + configuratiepaneel
├── shared/             # Riverpod-providers
└── widgets/            # App-schil, verbindingspil, sectiepaneel
```

Zie [ARCHITECTURE.md](ARCHITECTURE.md) voor een diepere technische uitleg.  
Zie [protocol_audit.md](protocol_audit.md) voor de seriële/BLE-framingdetails.

---

## Veelgestelde vragen

**De app vindt mijn USB-apparaat niet (Android)**  
Android vraagt toestemming voor USB-host-toegang. Accepteer het dialoogvenster dat verschijnt. De telefoon en kabel moeten ook USB OTG / USB-host ondersteunen; een laadkabel werkt meestal niet. Als Android MeshCLI NG niet aanbiedt voor het USB-apparaat, installeer dan de nieuwste APK en sluit de node opnieuw aan. Verschijnt de node nog steeds niet, gebruik dan BLE/TCP.

**De app vindt mijn seriële poort niet (Linux)**  
Voeg je gebruiker toe aan de groep `dialout`:
```sh
sudo usermod -a -G dialout $USER
```
Log daarna opnieuw in.

**clock sync stuurt de verkeerde tijd**  
De app gebruikt de systeemtijd van de pc/telefoon. Zorg dat die correct is ingesteld.

**Hoe weet ik de publieke sleutel van een remote repeater?**  
Verbind eerst in Companion-modus en typ `nodes` — de lijst toont alle bekende knooppunten met hun publieke sleutel (of prefix).

**De Config-knop is niet zichtbaar**  
De Config-knop verschijnt alleen in de **Repeater Serieel**-modus nadat je verbonden bent met een repeater.

**WiFi-instellingen werken niet direct na het opslaan**  
WiFi- en brugconfiguratie wordt pas actief na een herstart van het apparaat. Het configuratiepaneel laat dit weten en biedt de knop **Reboot now** aan.

---

## Referenties

- MeshCoreNG firmware: <https://github.com/meshcore-dev/MeshCoreNG>
- meshcore-cli (Python): <https://github.com/meshcore-dev/meshcore-cli>
- MeshCore protocol Python-pakket: `meshcore` (PyPI)
