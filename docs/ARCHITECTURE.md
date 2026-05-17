# MeshCLI NG Architecture

The app follows a reusable clean architecture layout:

- `core/transport`: Android USB serial, Linux/Windows serial, BLE UART, TCP gateway abstractions
- `core/protocol`: stable protocol constants and framing rules
- `core/parser`: safe binary parsers for companion responses and RF log packets
- `core/commands`: typed command builders and queue metadata
- `core/session`: connection state, command queue, response matching, monitor fanout
- `features/*`: screens and feature state
- `widgets` and `shared`: common UI and Riverpod providers

The session layer is transport-agnostic. BLE receives raw companion frames, serial decodes `0x3e` frames, and TCP is reserved for raw bridge/gateway mode.

Desktop support:

- Linux and Windows project scaffolds are generated.
- Linux/Windows serial uses `flutter_libserialport`.
- Android serial keeps using `usb_serial` for USB host permissions.
- BLE is mobile-only until a desktop BLE backend is selected.

Phase 1-3 are implemented as the foundation:

- USB/BLE discovery and connection plumbing
- connection states through Riverpod streams
- exact serial/BLE framing from Python MeshCore
- command queue with timeout handling
- console workflow for local companion commands and remote repeater CLI text commands
- raw RX/TX monitor with filtering, pause, color coding, duplicate detection
- node browser populated from contact/advert frames

Future layers should extend command builders first, then add feature repositories on top rather than parsing bytes in UI code.
