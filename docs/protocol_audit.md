# MeshCoreNG Protocol Audit

Sources inspected:

- Local Python package: `/home/michel/source/PyMesh/venv/lib/python3.12/site-packages/meshcore`
- Local firmware/docs: `/home/michel/source/MeshCoreNG`
- Upstream CLI: `https://github.com/meshcore-dev/meshcore-cli`

## Transport

BLE uses Nordic UART Service:

- service `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- write/RX `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- notify/TX `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`

BLE payloads are raw MeshCore companion command/response frames.

USB serial wraps outbound companion payloads as:

- start byte `0x3c`
- payload length `uint16 little-endian`
- payload bytes

Serial inbound frames use:

- start byte `0x3e`
- payload length `uint16 little-endian`
- payload bytes

Python rejects serial payload lengths over 300 bytes and resynchronizes by searching for the next inbound start byte.

## Command Surface

The Android app currently implements the Phase 1 core commands:

- `info`: command `0x01 0x03 "      mccli"`, waits for `SELF_INFO` or `ERROR`
- `firmware version`: command `0x16 0x03`, waits for `DEVICE_INFO` or `ERROR`
- `nodes`: command `0x04 [lastmod:u32le]`, consumes contact frames until `CONTACT_END`
- `statistics`: command `0x38 <statsType>`, waits for `STATS`
- `reboot`: command `0x13 "reboot"`, waits for `OK` or `ERROR`

The enum tables in `lib/core/packets/mesh_enums.dart` mirror the Python `meshcore.packets` values.

## Monitor Frames

RF log push frames use packet type `0x88`. Payload layout:

- signed SNR byte scaled by 4
- signed RSSI byte
- raw MeshCore RF packet payload

The RF packet header uses:

- route type: `header & 0x03`
- payload type: `(header & 0x3c) >> 2`
- payload version: `(header & 0xc0) >> 6`
- transport code is present for route types `0x00` and `0x03`
- path byte high two bits encode hash size minus one
- path byte low six bits encode hop/hash count

The monitor parser handles malformed frames with sentinel values instead of throwing.

## Compatibility Notes

`meshcore-cli` is a higher-level interactive client. Its README confirms BLE, Serial, and TCP companion transports, command chaining, node/contact management, repeater command forwarding, channel echoes, and log-based path/RSSI/SNR inspection. Protocol truth is in the `meshcore` Python package used by that CLI.
