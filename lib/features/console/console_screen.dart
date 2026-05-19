import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/commands/mesh_commands.dart';
import '../../core/models/connection_state.dart';
import '../../core/transport/serial/raw_serial_console.dart';
import '../../core/packets/mesh_enums.dart';
import '../../core/packets/mesh_event.dart';
import '../../shared/providers.dart';
import '../../shared/responsive.dart';
import '../../widgets/section_panel.dart';
import 'config_dialog.dart';

enum ConsoleMode { companion, repeater, directSerialRepeater }

class ConsoleScreen extends ConsumerStatefulWidget {
  const ConsoleScreen({super.key});

  @override
  ConsumerState<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends ConsumerState<ConsoleScreen> {
  final _commandController = TextEditingController();
  final _targetController = TextEditingController();
  final _scroll = ScrollController();
  final _lines = <_ConsoleLine>[];
  ConsoleMode _mode = ConsoleMode.companion;
  List<MeshDevice> _devices = const [];
  List<MeshDevice> _rawDevices = const [];
  MeshDevice? _rawDevice;
  String? _serialDeviceName;
  ProviderSubscription<AsyncValue<List<MeshEvent>>>? _eventSub;
  StreamSubscription<String>? _rawLineSub;
  bool _busy = false;
  bool _suppressRawLines = false;

  @override
  void initState() {
    super.initState();
    _eventSub = ref.listenManual(latestEventsProvider, (_, next) {
      if (!mounted) return;
      if (_mode == ConsoleMode.directSerialRepeater) return;
      final event = next.valueOrNull?.lastOrNull;
      if (event == null) return;
      if (event.type == MeshPacketType.contactMsgRecv ||
          event.type == MeshPacketType.contactMsgRecvV3) {
        _append('RX', _eventText(event));
      }
    });
    _rawLineSub = ref.read(rawSerialConsoleProvider).lines.listen((line) {
      if (_suppressRawLines) return;
      // In direct serial mode, suppress device echo and bare prompts.
      final name = _serialDeviceName;
      if (_mode == ConsoleMode.directSerialRepeater &&
          name != null &&
          line.trimRight().startsWith('$name>')) {
        return;
      }
      _append('RX', line);
    });
  }

  @override
  void dispose() {
    _eventSub?.close();
    _rawLineSub?.cancel();
    _commandController.dispose();
    _targetController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final rawText = _commandController.text;
    final text = rawText.trim();
    if (_busy) return;
    if (text.isEmpty && _mode != ConsoleMode.directSerialRepeater) return;
    if (!mounted) return;
    setState(() => _busy = true);
    final txLabel =
        _mode == ConsoleMode.directSerialRepeater && _serialDeviceName != null
            ? '$_serialDeviceName> $text'
            : text.isEmpty
                ? '<ENTER>'
                : text;
    _append('TX', txLabel);
    _commandController.clear();
    try {
      if (_mode == ConsoleMode.companion) {
        await _sendCompanion(text);
      } else if (_mode == ConsoleMode.repeater) {
        if (text.toLowerCase() == 'help') {
          _showRemoteHelp();
          return;
        }
        final session = ref.read(meshSessionProvider);
        final destination = _targetController.text.trim();
        if (destination.isEmpty) {
          throw ArgumentError('Remote mode needs a public key or prefix');
        }
        final event = await session.send(
          MeshCommands.remoteCli(
              destinationPublicKey: destination, command: text),
        );
        if (!mounted) return;
        _append('RX', _eventText(event));
      } else {
        final lower = text.toLowerCase();
        if (lower == 'help') {
          _showSerialHelp();
          return;
        }
        if (lower == 'config') {
          await _openSerialConfig();
          return;
        }
        if (lower == 'clock sync') {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          await ref.read(rawSerialConsoleProvider).sendLine('time $now');
          if (!mounted) return;
          _append('RX', 'clock sync sent: time $now');
          return;
        }
        await ref.read(rawSerialConsoleProvider).sendLine(text);
      }
    } catch (error) {
      if (!mounted) return;
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _append(String direction, String text) {
    if (!mounted) return;
    setState(() {
      _lines.add(_ConsoleLine(DateTime.now(), direction, text));
      if (_lines.length > 500) {
        _lines.removeRange(0, 100);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendCompanion(String text) async {
    final lower = text.toLowerCase();
    if (lower == 'help' || lower == 'get help' || lower == 'set help') {
      _showCompanionHelp();
      return;
    }
    if (lower.startsWith('get ')) {
      await _handleCompanionGet(lower.substring(4).trim());
      return;
    }
    if (lower.startsWith('set ')) {
      await _handleCompanionSet(text.substring(4).trim());
      return;
    }

    final commands = MeshCommands.companionConsole(text);
    for (final command in commands) {
      final event = await ref.read(meshSessionProvider).send(command);
      if (!mounted) return;
      _append('RX', _eventText(event));
    }
  }

  Future<void> _handleCompanionGet(String key) async {
    final session = ref.read(meshSessionProvider);
    if (key == 'battery') {
      _append('RX', _eventText(await session.send(MeshCommands.battery())));
      return;
    }
    if (key == 'time' || key == 'clock') {
      _append('RX', _eventText(await session.send(MeshCommands.getTime())));
      return;
    }
    if (key == 'firmware' ||
        key == 'ver' ||
        key == 'version' ||
        key == 'repeat' ||
        key == 'path.hash.mode') {
      final event = await session.send(MeshCommands.deviceQuery());
      if (!mounted) return;
      _append('RX', _formatGet(key, event));
      return;
    }

    final event = await session.send(MeshCommands.appStart());
    if (!mounted) return;
    _append('RX', _formatGet(key, event));
  }

  Future<void> _handleCompanionSet(String expression) async {
    final parts = expression.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      throw ArgumentError('set needs a key and value');
    }
    final key = parts.first.toLowerCase();
    final value = expression.substring(parts.first.length).trim();
    if (value.isEmpty) {
      throw ArgumentError('set $key needs a value');
    }
    final session = ref.read(meshSessionProvider);

    if (key == 'name') {
      final event = await session.send(MeshCommands.setName(value));
      if (!mounted) return;
      _append('RX', _eventText(event));
      return;
    }
    if (key == 'tx') {
      final event =
          await session.send(MeshCommands.setTxPower(int.parse(value)));
      if (!mounted) return;
      _append('RX', _eventText(event));
      return;
    }
    if (key == 'freq' ||
        key == 'bw' ||
        key == 'sf' ||
        key == 'cr' ||
        key == 'repeat') {
      final info = await session.send(MeshCommands.appStart());
      if (!mounted) return;
      if (info.isError) {
        _append('ERR', _eventText(info));
        return;
      }
      final freq = key == 'freq'
          ? double.parse(value)
          : (info.payload['radio_freq'] as num).toDouble();
      final bw = key == 'bw'
          ? double.parse(value)
          : (info.payload['radio_bw'] as num).toDouble();
      final sf =
          key == 'sf' ? int.parse(value) : info.payload['radio_sf'] as int;
      final cr =
          key == 'cr' ? int.parse(value) : info.payload['radio_cr'] as int;
      final repeat = key == 'repeat' ? _parseOnOff(value) : null;
      final event = await session.send(MeshCommands.setRadio(
          freq: freq, bw: bw, sf: sf, cr: cr, repeat: repeat));
      if (!mounted) return;
      _append('RX', _eventText(event));
      return;
    }

    throw ArgumentError('Unsupported companion set command: set $expression');
  }

  bool _parseOnOff(String value) {
    final normalized = value.toLowerCase();
    if (normalized == 'on' || normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'off' || normalized == 'false' || normalized == '0') {
      return false;
    }
    throw ArgumentError('Expected on/off');
  }

  @override
  Widget build(BuildContext context) {
    final selectedTransport = ref.watch(selectedTransportProvider);
    final connection = ref.watch(connectionStateProvider).valueOrNull;
    return SectionPanel(
      title: 'Console',
      actions: [
        _ModeControl(
          mode: _mode,
          busy: _busy,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = MeshResponsive.gap(context);
          final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboardOpen ? 4 : 0),
            child: Column(
              children: [
                if (_mode != ConsoleMode.directSerialRepeater)
                  _CompanionConnectionToolbar(
                    transport: selectedTransport,
                    devices: _devices,
                    snapshot: connection,
                    busy: _busy,
                    onTransportChanged: (transport) {
                      ref.read(selectedTransportProvider.notifier).state =
                          transport;
                      setState(() => _devices = const []);
                    },
                    onScan: _scanCompanion,
                    onConnect: _connectCompanion,
                    onDisconnect: _disconnectCompanion,
                  ),
                if (_mode == ConsoleMode.repeater)
                  Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: TextField(
                      controller: _targetController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.key),
                        labelText: 'Remote repeater public key/prefix hex',
                      ),
                    ),
                  ),
                if (_mode == ConsoleMode.directSerialRepeater)
                  _RawSerialToolbar(
                    devices: _rawDevices,
                    selected: _rawDevice,
                    busy: _busy,
                    onScan: _scanRawSerial,
                    onConnect: _connectRawSerial,
                    onDisconnect: _disconnectRawSerial,
                    onConfig:
                        _serialDeviceName != null ? _openSerialConfig : null,
                  ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xff050708),
                      border: Border.all(color: const Color(0xff1d2a30)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.symmetric(vertical: gap / 2),
                      itemCount: _lines.length,
                      itemBuilder: (context, index) =>
                          _ConsoleLineView(line: _lines[index]),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                _CommandBar(
                  controller: _commandController,
                  mode: _mode,
                  busy: _busy,
                  maxWidth: constraints.maxWidth,
                  onSend: _send,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _eventText(MeshEvent event) {
    if (event.isError) return 'ERROR ${jsonEncode(event.payload)}';
    if (event.type == MeshPacketType.msgSent) {
      return 'MSG_SENT ${jsonEncode(event.payload)}';
    }
    if (event.type == MeshPacketType.contactMsgRecv ||
        event.type == MeshPacketType.contactMsgRecvV3) {
      return '${event.payload['pubkey_prefix']}: ${event.payload['text']}';
    }
    return '${event.type?.name ?? 'event'} ${jsonEncode(event.payload)}';
  }

  Future<void> _scanCompanion() async {
    setState(() => _busy = true);
    try {
      final session = ref.read(meshSessionProvider);
      final selected = ref.read(selectedTransportProvider);
      final devices = await session.scan(type: selected);
      if (!mounted) return;
      setState(() => _devices = devices);
    } catch (error) {
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connectCompanion(MeshDevice device) async {
    setState(() => _busy = true);
    final session = ref.read(meshSessionProvider);
    try {
      await session.connect(device);
      if (!mounted) return;
      final info = await session.send(MeshCommands.appStart());
      final devQuery = await session.send(MeshCommands.deviceQuery());
      if (!mounted) return;

      final name = info.payload['name']?.toString() ?? device.name;
      final freq = (info.payload['radio_freq'] as num?)?.toStringAsFixed(4);
      final ver = (devQuery.payload['ver'] ??
              devQuery.payload['fw_build'] ??
              devQuery.payload['fw_ver'])
          ?.toString();

      _append(
        'RX',
        [
          'Connected! Device: $name',
          if (ver != null) 'version $ver',
          if (freq != null) 'freq: $freq MHz',
        ].join('  '),
      );
    } catch (error) {
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnectCompanion() async {
    setState(() => _busy = true);
    try {
      await ref.read(meshSessionProvider).disconnectCleanly();
      if (!mounted) return;
      _append('RX', 'companion disconnected');
    } catch (error) {
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanRawSerial() async {
    setState(() => _busy = true);
    try {
      final console = ref.read(rawSerialConsoleProvider);
      _append(
          'INFO', 'Scanning direct serial ports via ${console.backendLabel}');
      final devices = await console.scan();
      if (!mounted) return;
      setState(() => _rawDevices = devices);
    } catch (error) {
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _queryRawSerial(
      RawSerialConsole console, String command) async {
    final completer = Completer<String?>();
    final sub = console.lines.listen((line) {
      final match = RegExp(r'->\s*>\s*(.+)').firstMatch(line);
      if (match != null && !completer.isCompleted) {
        completer.complete(match.group(1)?.trim());
      }
    });
    try {
      await console.sendLine(command);
      return await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _connectRawSerial(MeshDevice device) async {
    setState(() => _busy = true);
    try {
      final console = ref.read(rawSerialConsoleProvider);
      _append('INFO',
          'INFO:meshcore:Connecting to repeater at ${device.id} (115200 baud)...');
      await console.connect(device);
      if (!mounted) return;
      setState(() {
        _rawDevice = device;
        _suppressRawLines = true;
      });

      final name = await _queryRawSerial(console, 'get name');
      final ver = await _queryRawSerial(console, 'ver');
      if (!mounted) return;

      setState(() {
        _serialDeviceName = name ?? device.name;
        _suppressRawLines = false;
      });

      final deviceName = _serialDeviceName!;
      _append('INFO',
          'Connected! Device: $deviceName${ver != null ? ' version $ver' : ''}');
      _append(
          'INFO', 'Type help for commands, quit to exit, Tab for completion');
      _append('INFO', '--------------------------------------------------');
    } catch (error) {
      if (mounted) setState(() => _suppressRawLines = false);
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnectRawSerial() async {
    setState(() => _busy = true);
    try {
      await ref.read(rawSerialConsoleProvider).disconnect();
      if (!mounted) return;
      setState(() {
        _rawDevice = null;
        _serialDeviceName = null;
        _suppressRawLines = false;
      });
      _append('INFO', 'INFO:meshcore:Disconnected from repeater.');
    } catch (error) {
      _append('ERR', '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatGet(String key, MeshEvent event) {
    if (event.isError) return _eventText(event);
    final payload = event.payload;
    final value = switch (key) {
      'name' => payload['name'],
      'freq' => payload['radio_freq'],
      'bw' => payload['radio_bw'],
      'sf' => payload['radio_sf'],
      'cr' => payload['radio_cr'],
      'tx' => payload['tx_power'],
      'public.key' || 'public_key' => payload['public_key'],
      'firmware' ||
      'ver' ||
      'version' =>
        payload['ver'] ?? payload['fw_build'] ?? payload['fw_ver'],
      'repeat' => payload['repeat'],
      'path.hash.mode' => payload['path_hash_mode'],
      _ => null,
    };
    if (value == null) return 'Unknown or unavailable get key: $key';
    return '$key = $value';
  }

  void _i(String text) => _append('INFO', text);

  Future<void> _openSerialConfig() async {
    if (_serialDeviceName == null) return;
    final console = ref.read(rawSerialConsoleProvider);
    final deviceName = _serialDeviceName!;
    setState(() => _suppressRawLines = true);
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SerialConfigDialog(
          deviceName: deviceName,
          queryParam: (key) => _queryRawSerial(console, 'get $key'),
          setParam: (key, value) => _queryRawSerial(console, 'set $key $value'),
          sendCommand: (cmd) => console.sendLine(cmd),
        ),
      );
    } finally {
      if (mounted) setState(() => _suppressRawLines = false);
    }
  }

  void _showCompanionHelp() {
    _i('=== Companion mode (mesh protocol) ===');
    _i('  info               – device info + firmware + battery');
    _i('  ver                – firmware version only');
    _i('  nodes              – contact list');
    _i('  clock              – device time');
    _i('  bat                – battery & storage');
    _i('  stats [core|radio|packets]  – statistics');
    _i('  reboot             – reboot device');
    _i('');
    _i('  get <param>:  name · freq · bw · sf · cr · tx · public.key');
    _i('               firmware · repeat · path.hash.mode · battery · time');
    _i('');
    _i('  set name <text>      – node name');
    _i('  set tx <dBm>         – TX power');
    _i('  set freq <MHz>       – frequency');
    _i('  set bw <kHz>         – bandwidth');
    _i('  set sf <n>           – spreading factor (5–12)');
    _i('  set cr <n>           – coding rate (5–8)');
    _i('  set repeat on|off    – packet forwarding');
  }

  void _showRemoteHelp() {
    _i('=== Remote repeater mode (commands sent via mesh) ===');
    _i('  ver · board · clock · reboot · poweroff · start ota');
    _i('  advert · advert.zerohop · discover.neighbors');
    _i('  neighbors · neighbor.remove <pubkey>');
    _i('  stats-core · stats-radio · stats-packets');
    _i('  sensor get <key> · sensor set <key> <val> · sensor list');
    _i('  region [list|get|put|remove|home|default|allowf|denyf|load|save]');
    _i('  gps · gps on|off · gps sync · gps setloc · gps advert [none|share|prefs]');
    _i('  tempradio <freq> <bw> <sf> <cr> <min>');
    _i('  password <pwd> · setperm <pubkey> <perm>');
    _i('');
    _i('  get <param>:  name · freq · bw · sf · cr · tx · af · role · repeat');
    _i('               lat · lon · public.key · advert.interval · flood.advert.interval');
    _i('               flood.max · flood.advert.base · flood.relay.prob · flood.dynamic.enable');
    _i('               path.hash.mode · loop.detect · multi.acks · int.thresh');
    _i('               guest.password · allow.read.only · owner.info');
    _i('               rxdelay · txdelay · direct.txdelay · dutycycle · adc.multiplier');
    _i('               bridge.type · bridge.enabled · bridge.delay · bridge.source');
    _i('               bridge.baud · bridge.channel · bridge.secret');
    _i('               wifi.ssid · bridge.server · bridge.port');
    _i('               wifi.status  – TCP bridge: WiFi connected, IP, RSSI, server state');
    _i('');
    _i('  set <param> <value>: same params as get (e.g. set repeat on, set name <text>)');
    _i('               set radio <freq> <bw> <sf> <cr>  – all radio params at once');
  }

  void _showSerialHelp() {
    _i('=== Direct serial repeater CLI (MeshCoreNG firmware) ===');
    _i('');
    _i('System:');
    _i('  ver · board · reboot · poweroff · shutdown · start ota');
    _i('  clock · clock sync · time <epoch>');
    _i('  powersaving [on|off]  · password <pwd>');
    _i('  tempradio <freq> <bw> <sf> <cr> <timeout_min>');
    _i('');
    _i('Network:');
    _i('  advert · advert.zerohop · discover.neighbors');
    _i('  neighbors · neighbor.remove <pubkey_hex>');
    _i('');
    _i('Statistics:');
    _i('  stats-core · stats-radio · stats-packets');
    _i('  clear stats · clear dense.stats · clear power.stats');
    _i('');
    _i('Logging:');
    _i('  log start · log stop · log · log erase');
    _i('');
    _i('Regions:');
    _i('  region · region list [allowed|denied]');
    _i('  region get/put/remove/home/default/allowf/denyf <name>');
    _i('  region load · region save');
    _i('');
    _i('Sensors:');
    _i('  sensor get <key> · sensor set <key> <val> · sensor list [start]');
    _i('');
    _i('GPS (if enabled):');
    _i('  gps · gps on|off · gps sync · gps setloc');
    _i('  gps advert [none|share|prefs]');
    _i('');
    _i('Access control:');
    _i('  get acl · setperm <pubkey_hex> <perm>');
    _i('');
    _i('get <param>:');
    _i('  name · freq · bw · sf · cr · tx · af · role · repeat');
    _i('  lat · lon · public.key · prv.key (serial only)');
    _i('  advert.interval · flood.advert.interval · flood.max');
    _i('  flood.advert.base · flood.relay.prob · flood.dynamic.enable');
    _i('  path.hash.mode · loop.detect · multi.acks · int.thresh · agc.reset.interval');
    _i('  rxdelay · txdelay · direct.txdelay · dutycycle · adc.multiplier');
    _i('  guest.password · allow.read.only · owner.info · radio · radio.rxgain');
    _i('  bridge.type · bridge.enabled · bridge.delay · bridge.source · bridge.baud');
    _i('  bridge.channel · bridge.secret · wifi.ssid · wifi.password');
    _i('  bridge.server · bridge.port · wifi.status (TCP bridge: WiFi+IP+RSSI+server state)');
    _i('  dense.stats · power.stats · bootloader.ver · pwrmgt.*  (hardware specific)');
    _i('');
    _i('set <param> <value>:');
    _i('  name <text>          tx <dBm>             freq <MHz>');
    _i('  bw <kHz>             sf <5-12>            cr <5-8>');
    _i('  af <factor>          lat <deg>            lon <deg>');
    _i('  repeat on|off        dutycycle <%>        radio.rxgain on|off');
    _i('  advert.interval <min>                     flood.advert.interval <h>');
    _i('  flood.max <n>        flood.advert.base <0.0-1.0>');
    _i('  flood.relay.prob <0-255>                  flood.dynamic.enable on|off');
    _i('  path.hash.mode <0-2> loop.detect off|minimal|moderate|strict');
    _i('  multi.acks 0|1       int.thresh <n>       agc.reset.interval <s>');
    _i('  rxdelay <ms>         txdelay <factor>     direct.txdelay <factor>');
    _i('  guest.password <pwd> allow.read.only on|off');
    _i('  owner.info <text>    adc.multiplier <0.0-10.0>  prv.key <hex>');
    _i('  radio <freq> <bw> <sf> <cr>');
    _i('  bridge.enabled on|off  bridge.delay <ms>  bridge.source tx|rx');
    _i('  bridge.baud <rate>   bridge.channel <1-14>  bridge.secret <s>');
    _i('  wifi.ssid <ssid>     wifi.password <pwd>');
    _i('  bridge.server <addr> bridge.port <1-65535>');
  }
}

class _ModeControl extends StatelessWidget {
  const _ModeControl({
    required this.mode,
    required this.busy,
    required this.onChanged,
  });

  final ConsoleMode mode;
  final bool busy;
  final ValueChanged<ConsoleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final mobile = MeshResponsive.isMobile(context);
    if (mobile) {
      return SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<ConsoleMode>(
          initialValue: mode,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.tune),
            labelText: 'Console mode',
          ),
          items: const [
            DropdownMenuItem(
              value: ConsoleMode.companion,
              child: Text('Companion'),
            ),
            DropdownMenuItem(
              value: ConsoleMode.repeater,
              child: Text('Remote'),
            ),
            DropdownMenuItem(
              value: ConsoleMode.directSerialRepeater,
              child: Text('-r Serial'),
            ),
          ],
          onChanged: busy
              ? null
              : (value) {
                  if (value != null) onChanged(value);
                },
        ),
      );
    }

    return SegmentedButton<ConsoleMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
            value: ConsoleMode.companion,
            icon: Icon(Icons.memory),
            label: Text('Companion')),
        ButtonSegment(
            value: ConsoleMode.repeater,
            icon: Icon(Icons.settings_input_antenna),
            label: Text('Remote')),
        ButtonSegment(
            value: ConsoleMode.directSerialRepeater,
            icon: Icon(Icons.cable),
            label: Text('-r Serial')),
      ],
      selected: {mode},
      onSelectionChanged: busy ? null : (value) => onChanged(value.first),
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.controller,
    required this.mode,
    required this.busy,
    required this.maxWidth,
    required this.onSend,
  });

  final TextEditingController controller;
  final ConsoleMode mode;
  final bool busy;
  final double maxWidth;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final mobile = maxWidth < MeshResponsive.mobileMax;
    final hint = switch (mode) {
      ConsoleMode.companion => mobile
          ? 'info, nodes, get freq, set tx 20'
          : 'info, ver, nodes, get freq, set tx 20, stats, reboot',
      ConsoleMode.repeater => mobile
          ? 'get freq, set repeat on'
          : 'get freq, set repeat on, get role, ...',
      ConsoleMode.directSerialRepeater => mobile
          ? 'serial CLI command'
          : 'direct serial CLI: get freq, set repeat on, clock sync, ...',
    };

    // The input row is intentionally outside the console scroller so Android
    // keyboard resize affects only available console height, not command access.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !busy,
            minLines: 1,
            maxLines: mobile ? 3 : 2,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.terminal),
              hintText: hint,
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
        SizedBox(width: MeshResponsive.gap(context)),
        if (mobile)
          IconButton.filled(
            onPressed: busy ? null : onSend,
            icon: const Icon(Icons.send),
            tooltip: 'Send',
          )
        else
          FilledButton.icon(
            onPressed: busy ? null : onSend,
            icon: const Icon(Icons.send),
            label: const Text('Send'),
          ),
      ],
    );
  }
}

class _CompanionConnectionToolbar extends StatelessWidget {
  const _CompanionConnectionToolbar({
    required this.transport,
    required this.devices,
    required this.snapshot,
    required this.busy,
    required this.onTransportChanged,
    required this.onScan,
    required this.onConnect,
    required this.onDisconnect,
  });

  final MeshTransportType transport;
  final List<MeshDevice> devices;
  final MeshConnectionSnapshot? snapshot;
  final bool busy;
  final ValueChanged<MeshTransportType> onTransportChanged;
  final VoidCallback onScan;
  final ValueChanged<MeshDevice> onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final gap = MeshResponsive.gap(context);
    final connected = switch (snapshot?.status) {
      MeshConnectionStatus.connected ||
      MeshConnectionStatus.authenticated =>
        true,
      _ => false,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < MeshResponsive.mobileMax;
          final transportSelector = SegmentedButton<MeshTransportType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                  value: MeshTransportType.usbSerial,
                  icon: Icon(Icons.usb),
                  label: Text('USB')),
              ButtonSegment(
                  value: MeshTransportType.ble,
                  icon: Icon(Icons.bluetooth),
                  label: Text('BLE')),
              ButtonSegment(
                  value: MeshTransportType.tcp,
                  icon: Icon(Icons.lan),
                  label: Text('TCP')),
            ],
            selected: {transport},
            onSelectionChanged:
                busy ? null : (value) => onTransportChanged(value.first),
          );
          final devicePicker = DropdownButtonFormField<MeshDevice>(
            initialValue: null,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link),
              labelText: 'Companion device',
            ),
            items: [
              for (final device in devices)
                DropdownMenuItem(
                  value: device,
                  child:
                      Text('${device.name}  ${device.subtitle ?? device.id}'),
                ),
            ],
            onChanged: busy || devices.isEmpty
                ? null
                : (device) {
                    if (device != null) onConnect(device);
                  },
          );
          final buttons = <Widget>[
            FilledButton.icon(
              onPressed: busy ? null : onScan,
              icon: const Icon(Icons.search),
              label: const Text('Scan'),
            ),
            OutlinedButton.icon(
              onPressed: busy || !connected ? null : onDisconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect'),
            ),
          ];

          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                transportSelector,
                SizedBox(height: gap),
                devicePicker,
                SizedBox(height: gap),
                Wrap(spacing: gap, runSpacing: gap, children: buttons),
              ],
            );
          }

          return Row(
            children: [
              transportSelector,
              SizedBox(width: gap),
              Expanded(child: devicePicker),
              SizedBox(width: gap),
              ...buttons.expand((button) => [button, SizedBox(width: gap)]),
            ]..removeLast(),
          );
        },
      ),
    );
  }
}

class _RawSerialToolbar extends StatelessWidget {
  const _RawSerialToolbar({
    required this.devices,
    required this.selected,
    required this.busy,
    required this.onScan,
    required this.onConnect,
    required this.onDisconnect,
    this.onConfig,
  });

  final List<MeshDevice> devices;
  final MeshDevice? selected;
  final bool busy;
  final VoidCallback onScan;
  final ValueChanged<MeshDevice> onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onConfig;

  @override
  Widget build(BuildContext context) {
    final gap = MeshResponsive.gap(context);
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < MeshResponsive.mobileMax;
          final portPicker = DropdownButtonFormField<MeshDevice>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.cable), labelText: 'Direct serial port'),
            items: [
              for (final device in devices)
                DropdownMenuItem(
                    value: device, child: Text('${device.name}  ${device.id}')),
            ],
            onChanged: busy || devices.isEmpty
                ? null
                : (device) {
                    if (device != null) onConnect(device);
                  },
          );
          final buttons = <Widget>[
            FilledButton.icon(
                onPressed: busy ? null : onScan,
                icon: const Icon(Icons.search),
                label: const Text('Scan')),
            if (onConfig != null)
              FilledButton.icon(
                  onPressed: busy ? null : onConfig,
                  icon: const Icon(Icons.tune),
                  label: const Text('Config')),
            OutlinedButton.icon(
                onPressed: busy || selected == null ? null : onDisconnect,
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect')),
          ];

          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                portPicker,
                SizedBox(height: gap),
                Wrap(spacing: gap, runSpacing: gap, children: buttons),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: portPicker),
              SizedBox(width: gap),
              ...buttons.expand((button) => [button, SizedBox(width: gap)]),
            ]..removeLast(),
          );
        },
      ),
    );
  }
}

class _ConsoleLine {
  const _ConsoleLine(this.time, this.direction, this.text);

  final DateTime time;
  final String direction;
  final String text;
}

class _ConsoleLineView extends StatelessWidget {
  const _ConsoleLineView({required this.line});

  final _ConsoleLine line;

  @override
  Widget build(BuildContext context) {
    final mobile = MeshResponsive.isMobile(context);
    final timeWidth = mobile ? 58.0 : 82.0;
    final directionWidth = mobile ? 34.0 : 42.0;
    final color = switch (line.direction) {
      'TX' => Colors.orangeAccent,
      'ERR' => Colors.redAccent,
      'INFO' => const Color(0xff88aabb),
      _ => Colors.greenAccent,
    };
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 6 : 10, vertical: 3),
      child: DefaultTextStyle(
        style: TextStyle(
            fontFamily: 'monospace',
            fontSize: mobile ? 11.5 : 13,
            height: 1.25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: timeWidth,
                child: Text(DateFormat.Hms().format(line.time),
                    style: const TextStyle(color: Colors.grey))),
            SizedBox(
                width: directionWidth,
                child: Text(line.direction, style: TextStyle(color: color))),
            Expanded(
                child: SelectableText(line.text,
                    style: const TextStyle(color: Color(0xffd7e7df)))),
          ],
        ),
      ),
    );
  }
}
