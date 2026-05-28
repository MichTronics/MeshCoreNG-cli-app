# MeshCLI NG

> 🇳🇱 Nederlandse versie: [docs/HANDLEIDING.md](docs/HANDLEIDING.md) · 🇩🇪 Deutsche Version: [docs/ANLEITUNG.md](docs/ANLEITUNG.md)

A Flutter console app for [MeshCoreNG](https://github.com/meshcore-dev) repeaters and companion radios.  
Connect over **USB serial**, **BLE**, or **TCP**, send CLI commands, and configure your mesh node — on Android, Linux, and Windows.

---

## What it does

MeshCLI NG gives you a terminal-style console for MeshCoreNG devices in three modes:

| Mode | What it connects to | Transport |
|---|---|---|
| **Companion** | A companion radio running the MeshCore companion firmware | BLE · USB · TCP |
| **Repeater Remote** | A remote repeater reached via the companion over the mesh | (via companion) |
| **Repeater Serial** | A repeater connected directly over USB serial | USB serial |

The app has no messaging UI and no node browser — it is a focused CLI console. In direct serial mode it also includes an interactive **configuration panel** that reads all settings from the device, lets you edit them, and sends only the changed values.

---

## Supported platforms

| Platform | USB serial | BLE | TCP |
|---|---|---|---|
| Android | ✅ | ✅ | ✅ |
| Linux | ✅ | — | ✅ |
| Windows | ✅ | — | ✅ |

Desktop BLE is not included; use serial or TCP on Linux/Windows.

### Android USB / OTG

For USB serial on Android the phone must support **USB OTG / USB host**.
This is needed because the MeshCore node is plugged directly into the phone, so the phone has to act as the USB host and give the app permission to open the serial port.

Use:
- a USB-C OTG adapter or USB-C data cable
- a MeshCore node/repeater that exposes a USB serial port
- Android's USB permission popup when the app scans/connects

When a supported USB serial node is plugged in, Android should offer **MeshCLI NG** as an app for that USB device. If it does not, install the newest APK, unplug/replug the node, and check that the cable is a data/OTG cable.

If OTG is not available, use **BLE** or **TCP** instead.

---

## Build & run

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.24
- For Android: Android SDK + a connected device or emulator
- For Linux: `libserialport` (`sudo apt install libserialport-dev`)
- For Windows: Visual Studio with **Desktop development with C++**

```sh
# Install dependencies
flutter pub get

# Android
flutter run -d android

# Linux desktop
flutter run -d linux

# Windows desktop
flutter run -d windows
```

---

## How to use

### 1 — Companion mode

Connects to a companion radio (the device you carry) using BLE, USB, or TCP.

1. Select the transport tab: **USB**, **BLE**, or **TCP**
2. Press **Scan** to discover devices
3. Select your device from the dropdown → it connects automatically
4. Type commands in the input field and press **Send** or Enter

On connect the app automatically queries the device and shows:
```
Connected! Device: MyNode  version 1.0.0-80abfbb  freq: 869.6180 MHz
```

**Available commands** (type `help` for the full list):

| Command | Description |
|---|---|
| `info` | Device name, firmware version, radio settings, battery |
| `ver` | Firmware version |
| `nodes` | List known contacts / neighbours |
| `clock` | Device time |
| `bat` | Battery level and storage |
| `stats [core\|radio\|packets]` | Statistics |
| `reboot` | Reboot the device |
| `get <param>` | Read a setting (see below) |
| `set <param> <value>` | Write a setting (see below) |

**get / set parameters:**

| Parameter | Description | set example |
|---|---|---|
| `name` | Node name | `set name MyRepeater` |
| `freq` | Radio frequency (MHz) | `set freq 869.5` |
| `bw` | Bandwidth (kHz) | `set bw 250` |
| `sf` | Spreading factor | `set sf 10` |
| `cr` | Coding rate | `set cr 5` |
| `tx` | TX power (dBm) | `set tx 20` |
| `repeat` | Packet forwarding on/off | `set repeat on` |
| `public.key` | Node public key | (read-only) |
| `firmware` | Firmware version | (read-only) |
| `battery` | Battery voltage | (read-only) |
| `time` | Device clock | (read-only via `clock`) |

---

### 2 — Repeater Remote mode

Sends CLI commands to a **remote repeater** over the mesh, relayed through your companion radio.

1. Switch to the **Repeater Remote** tab
2. Connect your companion radio first (see Companion mode above)
3. Paste the remote repeater's **public key** (or the first few hex bytes as a prefix) into the key field
4. Type any firmware CLI command and press **Send**

The command is delivered over the mesh and the response is shown in the console.  
Type `help` for the full list of supported Repeater Remote commands.

---

### 3 — Repeater Serial

Connects directly to a **repeater via USB serial**, bypassing the companion radio entirely.  
This is equivalent to `meshcore-cli -r -s /dev/ttyACM0`.

1. Switch to the **Repeater Serial** tab
2. Press **Scan** to list serial ports
3. Select the port of your repeater
4. The app connects, queries the device name and firmware version, and shows:

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

Every command you send is shown with the device name as a prompt.  
Device echo and bare prompts are filtered out automatically.

Type `help` to see all available firmware commands.  
`clock sync` is a special command that sends the current PC time to the device.

**Key firmware commands (serial):**

| Category | Commands |
|---|---|
| Info | `ver` · `board` · `clock` · `clock sync` |
| Radio | `get radio` → freq, bw, sf, cr · `set freq <MHz>` · `set bw <kHz>` · `set sf <n>` · `set cr <n>` · `set tx <dBm>` |
| Network | `advert` · `advert.zerohop` · `discover.neighbors` · `neighbors` |
| Statistics | `stats-core` · `stats-radio` · `stats-packets` · `clear stats` |
| Logging | `log start` · `log stop` · `log` · `log erase` |
| Sensors | `sensor get <key>` · `sensor set <key> <val>` · `sensor list` |
| GPS | `gps` · `gps on\|off` · `gps sync` · `gps setloc` · `gps advert` |
| Regions | `region` · `region list` · `region get/put/remove` · `regiondb find` · … |
| Power | `powersaving on\|off` · `reboot` · `poweroff` · `start ota` |
| Access | `get acl` · `setperm <pubkey> <perm>` · `password <pwd>` |
| TCP bridge | `get wifi.status` → WiFi state, IP address, RSSI, server connection |

> **Note:** `get radio` returns `freq,bw,sf,cr` as a single comma-separated response. There are no individual `get sf`, `get bw`, or `get cr` commands in the firmware — use `set sf <n>` etc. to change them individually.

#### Configuration panel

After connecting, a **Config** button appears in the toolbar. Click it — or type `config` in the command field — to open an interactive panel that:

- Reads all configurable parameters from the device (grouped by category)
- Shows current values in editable text fields and dropdowns
- Highlights any field you change with an orange tint
- On **Apply changes**, sends only the modified `set` commands to the device and shows ✓ or ✗ per parameter
- Recognises **WiFi / bridge settings** that require a reboot: after applying them a warning banner appears with a **Reboot now** button
- Includes a **Regions** step for home/default scope, flood allow/deny lists, Dutch location lookup, and a preset that adds `de` plus all 16 German states
- Uses a local Dutch `regiondb` lookup table in the app, so `regiondb find <prefix>` also works when the firmware database is disabled

**Parameter sections in the config panel:**

| Section | Parameters |
|---|---|
| Identity | `name` · `owner.info` · `lat` · `lon` |
| Radio | `freq` · `bw` · `sf` · `cr` · `tx` · `af` · `repeat` · `dutycycle` · `radio.rxgain` |
| Advertising | `advert.interval` · `flood.advert.interval` |
| Flood / Routing | `flood.max` · `flood.advert.base` · `flood.relay.prob` · `flood.dynamic.enable` · `path.hash.mode` · `loop.detect` · `multi.acks` · `int.thresh` · `rxdelay` · `txdelay` · `direct.txdelay` · `agc.reset.interval` |
| Access | `guest.password` · `allow.read.only` |
| TCP Bridge | `bridge.enabled` · `wifi.ssid` · `wifi.password` · `bridge.server` · `bridge.port` · `bridge.delay` |
| ESPNow Bridge | `bridge.source` · `bridge.baud` · `bridge.channel` · `bridge.secret` |
| Regions | `region home` · `region default` · `region allowf/denyf` · `region put` · `regiondb find` |

WiFi password fields are write-only (never fetched from the device). Leave blank to keep the current password unchanged.  
All TCP Bridge and ESPNow Bridge settings require a device reboot before they take effect.

---

## Console output colours

| Colour | Meaning |
|---|---|
| Orange | Command you sent (TX) |
| Green | Response from device (RX) |
| Blue-grey | Info / status messages |
| Red | Error |

---

## Project structure

```
lib/
├── core/
│   ├── commands/       # Typed command builders (MeshCommands)
│   ├── models/         # Connection state, MeshNode
│   ├── packets/        # Packet type enums and event models
│   ├── parser/         # Binary frame parsers
│   ├── protocol/       # Serial framing constants
│   ├── session/        # Command queue, response matching, state streams
│   └── transport/      # BLE, USB serial, desktop serial, TCP transports
├── features/
│   └── console/        # Main console screen + config dialog
├── shared/             # Riverpod providers
└── widgets/            # App shell, connection pill, section panel
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a deeper explanation.  
See [docs/protocol_audit.md](docs/protocol_audit.md) for the serial/BLE framing details.

---

## Troubleshooting

**Android does not find my USB node**
Accept the Android USB permission dialog. The phone and cable must also support USB OTG / USB host; charge-only cables usually do not work. If Android does not offer MeshCLI NG for the USB device, install the newest APK and reconnect the node. If the node still does not appear, use BLE/TCP.

---

## References

- MeshCoreNG firmware: <https://github.com/meshcore-dev/MeshCoreNG>
- meshcore-cli (Python): <https://github.com/meshcore-dev/meshcore-cli>
- MeshCore protocol Python package: `meshcore` (PyPI)
