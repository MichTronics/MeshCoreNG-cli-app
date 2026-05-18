# MeshCLI NG

> 🇳🇱 Nederlandse versie: [docs/HANDLEIDING.md](docs/HANDLEIDING.md)

A Flutter console app for [MeshCoreNG](https://github.com/meshcore-dev) repeaters and companion radios.  
Connect over **USB serial**, **BLE**, or **TCP**, send CLI commands, and manage your mesh node — on Android, Linux, and Windows.

---

## What it does

MeshCLI NG gives you a terminal-style console for MeshCoreNG devices in three modes:

| Mode | What it connects to | Transport |
|---|---|---|
| **Companion** | A companion radio running the MeshCore companion firmware | BLE · USB · TCP |
| **Remote** | A remote repeater reached via the companion over the mesh | (via companion) |
| **-r Serial** | A repeater connected directly over USB serial | USB serial |

The app intentionally has no messaging UI, no node browser, and no config dashboard — it is a focused CLI console.

---

## Supported platforms

| Platform | USB serial | BLE | TCP |
|---|---|---|---|
| Android | ✅ | ✅ | ✅ |
| Linux | ✅ | — | ✅ |
| Windows | ✅ | — | ✅ |

Desktop BLE is not included; use serial or TCP on Linux/Windows.

---

## Build & run

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.4
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

### 2 — Remote mode

Sends CLI commands to a **remote repeater** over the mesh, relayed through your companion radio.

1. Switch to the **Remote** tab
2. Connect your companion radio first (see Companion mode above)
3. Paste the remote repeater's **public key** (or the first few hex bytes as a prefix) into the key field
4. Type any firmware CLI command and press **Send**

The command is delivered over the mesh and the response is shown in the console.  
Type `help` for the full list of supported remote commands.

---

### 3 — Direct serial (-r Serial)

Connects directly to a **repeater via USB serial**, bypassing the companion radio entirely.  
This is equivalent to `meshcore-cli -r -s /dev/ttyACM0`.

1. Switch to the **-r Serial** tab
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
| Radio | `get freq` · `set freq <MHz>` · `get sf` · `set sf <n>` · … |
| Network | `advert` · `advert.zerohop` · `discover.neighbors` · `neighbors` |
| Statistics | `stats-core` · `stats-radio` · `stats-packets` · `clear stats` |
| Logging | `log start` · `log stop` · `log` · `log erase` |
| Sensors | `sensor get <key>` · `sensor set <key> <val>` · `sensor list` |
| GPS | `gps` · `gps on\|off` · `gps sync` · `gps setloc` · `gps advert` |
| Regions | `region` · `region list` · `region get/put/remove` · … |
| Power | `powersaving on\|off` · `reboot` · `poweroff` · `start ota` |
| Access | `get acl` · `setperm <pubkey> <perm>` · `password <pwd>` |
| TCP bridge | `get wifi.status` → WiFi state, IP address, RSSI, server connection |

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
│   └── console/        # Main console screen with all three modes
├── shared/             # Riverpod providers
└── widgets/            # App shell, connection pill, section panel
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a deeper explanation.  
See [docs/protocol_audit.md](docs/protocol_audit.md) for the serial/BLE framing details.

---

## References

- MeshCoreNG firmware: <https://github.com/meshcore-dev/MeshCoreNG>
- meshcore-cli (Python): <https://github.com/meshcore-dev/meshcore-cli>
- MeshCore protocol Python package: `meshcore` (PyPI)
