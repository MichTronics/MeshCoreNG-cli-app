# MeshCLI NG — Anleitung

> 🇬🇧 English version: [README.md](../README.md) · 🇳🇱 Nederlandse versie: [HANDLEIDING.md](HANDLEIDING.md)

Eine Flutter-Konsolen-App für MeshCoreNG-Repeater und Companion-Radios.  
Verbinde dich über **USB seriell**, **BLE** oder **TCP** und sende CLI-Befehle an deinen Mesh-Knoten, auf Android, Linux und Windows.

---

## Was macht die App?

MeshCLI NG bietet ein Terminalfenster für MeshCoreNG-Geräte in drei Modi:

| Modus | Verbindung zu | Transport |
|---|---|---|
| **Companion** | Ein Companion-Radio mit MeshCore-Companion-Firmware | BLE · USB · TCP |
| **Remote** | Ein entfernter Repeater, erreichbar über den Companion im Mesh | (über Companion) |
| **-r Serial** | Ein Repeater direkt über USB seriell | USB seriell |

Die App hat keine Chat-Oberfläche und keine Kontaktliste. Sie ist eine kompakte CLI-Konsole. Im direkten seriellen Modus gibt es außerdem ein interaktives **Konfigurationspanel**, mit dem du alle Einstellungen deines Repeaters auslesen, bearbeiten und zurückschreiben kannst.

---

## Unterstützte Plattformen

| Plattform | USB seriell | BLE | TCP |
|---|---|---|---|
| Android | ✅ | ✅ | ✅ |
| Linux | ✅ | — | ✅ |
| Windows | ✅ | — | ✅ |

Desktop-BLE ist nicht enthalten; verwende unter Linux/Windows seriell oder TCP.

### Android USB / OTG

Für USB seriell auf Android muss das Telefon **USB OTG / USB Host** unterstützen.
Das ist nötig, weil der MeshCore-Knoten direkt am Telefon hängt: Das Telefon muss dann USB-Host sein und der App erlauben, den seriellen Port zu öffnen.

Verwende:
- einen USB-C-OTG-Adapter oder ein USB-C-Datenkabel
- einen MeshCore-Knoten/Repeater, der als USB-Seriell-Port erscheint
- die Android-USB-Berechtigung, die beim Scannen oder Verbinden erscheint

Wenn du einen unterstützten USB-seriellen Knoten anschließt, sollte Android **MeshCLI NG** als App für dieses USB-Gerät anbieten. Passiert das nicht, installiere die neueste APK, stecke den Knoten aus und wieder ein, und prüfe, ob das Kabel wirklich Daten/OTG unterstützt.

Wenn dein Telefon kein OTG hat oder das Kabel nur zum Laden geeignet ist, verwende **BLE** oder **TCP**.

---

## Installation und Start

### Voraussetzungen

- [Flutter SDK](https://docs.flutter.dev/get-started/install) Version 3.24 oder höher
- Android: Android SDK + ein angeschlossenes Telefon oder ein Emulator
- Linux: `libserialport` (`sudo apt install libserialport-dev`)
- Windows: Visual Studio mit **Desktop development with C++**

```sh
# Abhängigkeiten installieren
flutter pub get

# Android
flutter run -d android

# Linux Desktop
flutter run -d linux

# Windows Desktop
flutter run -d windows
```

---

## Verwendung

### Modus 1 — Companion

Verbindet sich mit einem Companion-Radio über BLE, USB oder TCP.

**Schritte:**
1. Wähle den Transport-Tab: **USB**, **BLE** oder **TCP**
2. Drücke **Scan**, um verfügbare Geräte zu suchen
3. Wähle dein Gerät aus der Liste; die App verbindet automatisch
4. Gib einen Befehl in das Eingabefeld ein und drücke **Send** oder Enter

Beim Verbinden fragt die App automatisch die Geräteinformationen ab und zeigt:

```
Connected! Device: MeinNode  version 1.0.0-80abfbb  freq: 869.6180 MHz
```

**Verfügbare Befehle** (`help` zeigt die vollständige Liste):

| Befehl | Beschreibung |
|---|---|
| `info` | Gerätename, Firmware-Version, Funkeinstellungen, Batterie |
| `ver` | Nur Firmware-Version |
| `nodes` | Liste bekannter Kontakte / Nachbarn |
| `clock` | Gerätezeit |
| `bat` | Batteriespannung und Speicher |
| `stats [core\|radio\|packets]` | Statistiken |
| `reboot` | Gerät neu starten |
| `get <param>` | Einstellung lesen (siehe Tabelle) |
| `set <param> <wert>` | Einstellung ändern (siehe Tabelle) |

**get / set Parameter:**

| Parameter | Beschreibung | Beispiel |
|---|---|---|
| `name` | Name des Knotens | `set name MeinRepeater` |
| `freq` | Funkfrequenz (MHz) | `set freq 869.5` |
| `bw` | Bandbreite (kHz) | `set bw 250` |
| `sf` | Spreading Factor | `set sf 10` |
| `cr` | Coding Rate | `set cr 5` |
| `tx` | Sendeleistung (dBm) | `set tx 20` |
| `repeat` | Paketweiterleitung ein/aus | `set repeat on` |
| `public.key` | Öffentlicher Schlüssel des Knotens | (nur lesen) |
| `firmware` | Firmware-Version | (nur lesen) |
| `battery` | Batteriespannung | (nur lesen) |
| `time` | Geräteuhr | (über `clock`) |

---

### Modus 2 — Remote

Sendet CLI-Befehle an einen **entfernten Repeater** über das Mesh-Netzwerk, weitergeleitet durch dein Companion-Radio.

**Schritte:**
1. Klicke auf den Tab **Remote**
2. Verbinde zuerst dein Companion-Radio (siehe oben)
3. Füge den **öffentlichen Schlüssel** des entfernten Repeaters in das Schlüsselfeld ein (oder die ersten Hex-Bytes als Prefix)
4. Gib einen Firmware-CLI-Befehl ein und drücke **Send**

Der Befehl wird über das Mesh ausgeliefert und die Antwort erscheint in der Konsole.  
`help` zeigt die vollständige Liste unterstützter Remote-Befehle.

---

### Modus 3 — Direkt seriell (-r Serial)

Verbindet direkt mit einem **Repeater über USB seriell**, ohne Companion-Radio dazwischen.  
Das entspricht `meshcore-cli -r -s /dev/ttyACM0`.

**Schritte:**
1. Klicke auf den Tab **-r Serial**
2. Drücke **Scan**, um verfügbare serielle Ports zu suchen
3. Wähle den Port deines Repeaters
4. Die App verbindet, fragt Gerätename und Firmware-Version ab und zeigt:

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

Jeder Befehl, den du eingibst, wird mit dem Gerätenamen als Prompt angezeigt.  
Echo-Zeilen und leere Prompts des Geräts werden automatisch herausgefiltert.

`help` zeigt alle verfügbaren Firmware-Befehle.  
`clock sync` ist ein spezieller Befehl, der die aktuelle PC-Zeit an das Gerät sendet.

**Wichtige Firmware-Befehle (seriell):**

| Kategorie | Befehle |
|---|---|
| Info | `ver` · `board` · `clock` · `clock sync` |
| Funk | `get radio` → freq, bw, sf, cr · `set freq <MHz>` · `set bw <kHz>` · `set sf <n>` · `set cr <n>` · `set tx <dBm>` |
| Netzwerk | `advert` · `advert.zerohop` · `discover.neighbors` · `neighbors` |
| Statistiken | `stats-core` · `stats-radio` · `stats-packets` · `clear stats` |
| Logging | `log start` · `log stop` · `log` · `log erase` |
| Sensoren | `sensor get <schlüssel>` · `sensor set <schlüssel> <wert>` · `sensor list` |
| GPS | `gps` · `gps on\|off` · `gps sync` · `gps setloc` · `gps advert` |
| Regionen | `region` · `region list` · `region get/put/remove` · `regiondb find` · … |
| Energie | `powersaving on\|off` · `reboot` · `poweroff` · `start ota` |
| Zugriff | `get acl` · `setperm <pubkey> <rechte>` · `password <passwort>` |
| TCP-Brücke | `get wifi.status` → WiFi-Status, IP-Adresse, RSSI, Serververbindung |

> **Hinweis:** `get radio` gibt `freq,bw,sf,cr` als einen kommaseparierten Wert zurück. Die Firmware hat keine separaten `get sf`, `get bw` oder `get cr` Befehle. Verwende `set sf <n>` usw., um sie einzeln anzupassen.

#### Konfigurationspanel

Sobald du verbunden bist, erscheint die Schaltfläche **Config** in der Werkzeugleiste. Klicke darauf oder gib `config` in das Eingabefeld ein, um ein interaktives Panel zu öffnen, das:

- alle konfigurierbaren Parameter vom Gerät ausliest (nach Kategorien gruppiert)
- aktuelle Werte in bearbeitbaren Textfeldern und Auswahllisten zeigt
- jedes geänderte Feld orange markiert
- bei **Apply changes** nur die geänderten `set`-Befehle an das Gerät sendet und ✓ oder ✗ pro Parameter zeigt
- **WiFi- und Brücken-Einstellungen** erkennt, die einen Neustart benötigen: Nach dem Anwenden erscheint ein Warnbanner mit **Reboot now**
- einen Schritt **Regionen** enthält für Home/Default-Scope, Flood-Allow/Deny-Listen, niederländische Standortsuche und ein Preset, das `de` plus alle 16 deutschen Bundesländer hinzufügt

**Parametergruppen im Konfigurationspanel:**

| Abschnitt | Parameter |
|---|---|
| Identity | `name` · `owner.info` · `lat` · `lon` |
| Radio | `freq` · `bw` · `sf` · `cr` · `tx` · `af` · `repeat` · `dutycycle` · `radio.rxgain` |
| Advertising | `advert.interval` · `flood.advert.interval` |
| Flood / Routing | `flood.max` · `flood.advert.base` · `flood.relay.prob` · `flood.dynamic.enable` · `path.hash.mode` · `loop.detect` · `multi.acks` · `int.thresh` · `rxdelay` · `txdelay` · `direct.txdelay` · `agc.reset.interval` |
| Access | `guest.password` · `allow.read.only` |
| TCP Bridge | `bridge.enabled` · `wifi.ssid` · `wifi.password` · `bridge.server` · `bridge.port` · `bridge.delay` |
| ESPNow Bridge | `bridge.source` · `bridge.baud` · `bridge.channel` · `bridge.secret` |
| Regionen | `region home` · `region default` · `region allowf/denyf` · `region put` · `regiondb find` |

Das WiFi-Passwortfeld ist nur schreibend (es wird nie vom Gerät gelesen). Lass es leer, um das aktuelle Passwort unverändert zu lassen.  
Alle TCP-Bridge- und ESPNow-Bridge-Einstellungen benötigen einen Neustart des Geräts, bevor sie aktiv werden.

---

## Konsolenfarben

| Farbe | Bedeutung |
|---|---|
| Orange | Befehl, den du gesendet hast (TX) |
| Grün | Antwort des Geräts (RX) |
| Blaugrau | Info / Statusmeldungen |
| Rot | Fehler |

---

## Projektstruktur

```
lib/
├── core/
│   ├── commands/       # Typisierte Command-Builder (MeshCommands)
│   ├── models/         # Verbindungsstatus, MeshNode
│   ├── packets/        # Pakettyp-Enums und Event-Modelle
│   ├── parser/         # Binäre Frame-Parser
│   ├── protocol/       # Serielle Framing-Konstanten
│   ├── session/        # Command-Queue, Response-Matching, Status-Streams
│   └── transport/      # BLE, USB seriell, Desktop seriell, TCP-Transporte
├── features/
│   └── console/        # Hauptkonsolenbildschirm + Konfigurationspanel
├── shared/             # Riverpod-Provider
└── widgets/            # App-Shell, Verbindungspille, Abschnittspanel
```

Siehe [ARCHITECTURE.md](ARCHITECTURE.md) für eine ausführlichere technische Erklärung.  
Siehe [protocol_audit.md](protocol_audit.md) für Details zum seriellen/BLE-Framing.

---

## Häufige Fragen

**Die App findet mein USB-Gerät nicht (Android)**  
Android fragt nach Berechtigung für USB-Host-Zugriff. Akzeptiere den Dialog, der erscheint. Telefon und Kabel müssen außerdem USB OTG / USB Host unterstützen; ein reines Ladekabel funktioniert meistens nicht. Wenn Android MeshCLI NG nicht für das USB-Gerät anbietet, installiere die neueste APK und schließe den Knoten erneut an. Erscheint der Knoten weiterhin nicht, verwende BLE/TCP.

**Die App findet meinen seriellen Port nicht (Linux)**  
Füge deinen Benutzer zur Gruppe `dialout` hinzu:

```sh
sudo usermod -a -G dialout $USER
```

Melde dich danach neu an.

**clock sync sendet die falsche Zeit**  
Die App verwendet die Systemzeit des PCs/Telefons. Stelle sicher, dass sie korrekt eingestellt ist.

**Wie finde ich den öffentlichen Schlüssel eines Remote-Repeaters?**  
Verbinde zuerst im Companion-Modus und gib `nodes` ein. Die Liste zeigt alle bekannten Knoten mit öffentlichem Schlüssel (oder Prefix).

**Die Config-Schaltfläche ist nicht sichtbar**  
Die Config-Schaltfläche erscheint nur im **-r Serial**-Modus, nachdem du mit einem Repeater verbunden bist.

**WiFi-Einstellungen wirken nicht direkt nach dem Speichern**  
WiFi- und Brückenkonfiguration wird erst nach einem Neustart des Geräts aktiv. Das Konfigurationspanel weist darauf hin und bietet die Schaltfläche **Reboot now** an.

---

## Referenzen

- MeshCoreNG-Firmware: <https://github.com/meshcore-dev/MeshCoreNG>
- meshcore-cli (Python): <https://github.com/meshcore-dev/meshcore-cli>
- MeshCore-Protokoll-Python-Paket: `meshcore` (PyPI)
