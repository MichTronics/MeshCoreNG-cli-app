// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/commands/mesh_commands.dart';
import '../../core/models/connection_state.dart';
import '../../core/packets/mesh_enums.dart';
import '../../core/packets/mesh_event.dart';
import '../../core/regions/dutch_region_db.dart';
import '../../core/transport/serial/raw_serial_console.dart';
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
  final _commandFocus = FocusNode();
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
  bool _showCommands = true;

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
    _commandFocus.dispose();
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
          throw ArgumentError(
              'Repeater Remote mode needs a public key or prefix');
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
        if (lower == 'wizard' || lower == 'config wizard') {
          await _openSerialWizard();
          return;
        }
        if (lower == 'clock sync') {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          await ref.read(rawSerialConsoleProvider).sendLine('time $now');
          if (!mounted) return;
          _append('RX', 'clock sync sent: time $now');
          return;
        }
        final localRegionDbResponse = DutchRegionDb.handleCommand(text);
        if (localRegionDbResponse != null) {
          _append('RX', localRegionDbResponse);
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
        IconButton.filledTonal(
          onPressed: () => setState(() => _showCommands = !_showCommands),
          icon: Icon(_showCommands ? Icons.view_list : Icons.view_module),
          tooltip: _showCommands ? 'Hide commands' : 'Show commands',
        ),
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
                        labelText: 'Repeater Remote public key/prefix hex',
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
                    onWizard:
                        _serialDeviceName != null ? _openSerialWizard : null,
                  ),
                if (_showCommands)
                  Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: _CommandPalette(
                      mode: _mode,
                      onSelected: _stageCommand,
                    ),
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
                  focusNode: _commandFocus,
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
      final match = RegExp(r'->\s*(?:>\s*)?(.+)').firstMatch(line);
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

  Future<String?> _queryRegionAwareRawSerial(
      RawSerialConsole console, String command) async {
    final localRegionDbResponse = DutchRegionDb.handleCommand(command);
    if (localRegionDbResponse != null) return localRegionDbResponse;
    return _queryRawSerial(console, command);
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

  void _stageCommand(String command) {
    _commandController.text = command;
    _commandController.selection =
        TextSelection.collapsed(offset: command.length);
    _commandFocus.requestFocus();
  }

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
          setParam: (key, value) => key == 'admin.password'
              ? _queryRawSerial(console, 'password $value')
              : _queryRawSerial(console, 'set $key $value'),
          sendCommand: (cmd) => console.sendLine(cmd),
        ),
      );
    } finally {
      if (mounted) setState(() => _suppressRawLines = false);
    }
  }

  Future<void> _openSerialWizard() async {
    if (_serialDeviceName == null) return;
    final console = ref.read(rawSerialConsoleProvider);
    final deviceName = _serialDeviceName!;
    setState(() => _suppressRawLines = true);
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SerialConfigWizardDialog(
          deviceName: deviceName,
          queryParam: (key) => _queryRawSerial(console, 'get $key'),
          queryCommand: (cmd) => _queryRegionAwareRawSerial(console, cmd),
          setParam: (key, value) => key == 'admin.password'
              ? _queryRawSerial(console, 'password $value')
              : _queryRawSerial(console, 'set $key $value'),
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
    _i('=== Repeater Remote mode (commands sent via mesh) ===');
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
    _i('=== Repeater Serial CLI (MeshCoreNG firmware) ===');
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
    _i('  regiondb info/provinces/find/get/code  – local Dutch lookup');
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
              child: Text('Repeater Remote'),
            ),
            DropdownMenuItem(
              value: ConsoleMode.directSerialRepeater,
              child: Text('Repeater Serial'),
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
            label: Text('Repeater Remote')),
        ButtonSegment(
            value: ConsoleMode.directSerialRepeater,
            icon: Icon(Icons.cable),
            label: Text('Repeater Serial')),
      ],
      selected: {mode},
      onSelectionChanged: busy ? null : (value) => onChanged(value.first),
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.controller,
    required this.focusNode,
    required this.mode,
    required this.busy,
    required this.maxWidth,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
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
            focusNode: focusNode,
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

class _CliCommandCategory {
  const _CliCommandCategory(this.title, this.commands);

  final String title;
  final List<_CliCommandAction> commands;
}

class _CliCommandAction {
  const _CliCommandAction(this.label, this.command);

  final String label;
  final String command;

  String get tooltip => '$command\n\n${_describeCliCommand(command)}';
}

String _describeCliCommand(String command) {
  final normalized = command.trim();
  final lower = normalized.toLowerCase();

  if (lower == 'help')
    return 'Show the available commands for this console mode.';
  if (lower == 'info')
    return 'Read device info, firmware details, radio settings and battery status.';
  if (lower == 'ver') return 'Show the firmware version and build date.';
  if (lower == 'board')
    return 'Show the hardware or board name reported by the firmware.';
  if (lower == 'nodes' || lower == 'contacts' || lower == 'peers') {
    return 'List known contacts or mesh nodes from the companion device.';
  }
  if (lower == 'clock') return 'Show the node clock in UTC.';
  if (lower == 'clock sync')
    return 'Set the node clock from the current computer or phone time.';
  if (lower == 'clkreboot')
    return 'Reset the node clock to the firmware fallback time and reboot.';
  if (lower.startsWith('time '))
    return 'Set the node clock to a Unix epoch timestamp.';
  if (lower == 'bat' || lower == 'battery')
    return 'Read battery and storage statistics.';
  if (lower == 'reboot') return 'Reboot the node.';
  if (lower == 'poweroff' || lower == 'shutdown')
    return 'Power off the node when the board supports it.';
  if (lower == 'erase')
    return 'Factory erase the local filesystem. Serial only and destructive.';
  if (lower == 'start ota')
    return 'Start manual OTA update mode on supported boards.';
  if (lower == 'ota.check')
    return 'Check online OTA availability using the saved WiFi credentials.';
  if (lower == 'ota.update')
    return 'Download and install an available online OTA update.';
  if (lower == 'config')
    return 'Open the full direct-serial configuration editor.';
  if (lower == 'config wizard')
    return 'Open the guided setup wizard for common repeater settings.';

  if (lower == 'advert') return 'Send a normal flood advertisement now.';
  if (lower == 'advert.zerohop')
    return 'Send a zero-hop advertisement for direct neighbors only.';
  if (lower == 'discover.neighbors')
    return 'Ask nearby nodes to advertise so neighbors can be discovered.';
  if (lower == 'neighbors') return 'List recently heard zero-hop neighbors.';
  if (lower.startsWith('neighbor.remove'))
    return 'Remove one neighbor by public-key prefix, or all with an empty prefix.';

  if (lower == 'stats' || lower == 'statistics')
    return 'Read the main stats groups.';
  if (lower == 'stats core' || lower == 'stats-core')
    return 'Show battery, uptime, queue and core system counters.';
  if (lower == 'stats radio' || lower == 'stats-radio')
    return 'Show radio counters such as RSSI, SNR, noise and airtime.';
  if (lower == 'stats packets' || lower == 'stats-packets')
    return 'Show packet transmit and receive counters.';
  if (lower == 'clear stats') return 'Reset general runtime statistics.';
  if (lower == 'clear dense.stats') return 'Reset dense-mesh runtime counters.';
  if (lower == 'clear spam.stats')
    return 'Reset spam and malformed public-chat counters.';
  if (lower == 'clear power.stats')
    return 'Reset power-management runtime counters.';
  if (lower == 'log start')
    return 'Start capturing the receive log to node storage.';
  if (lower == 'log stop') return 'Stop receive-log capture.';
  if (lower == 'log') return 'Print the stored receive log. Serial only.';
  if (lower == 'log erase') return 'Erase the stored receive log.';

  if (lower == 'powersaving')
    return 'Show whether repeater power saving is enabled.';
  if (lower == 'powersaving on')
    return 'Enable repeater power-saving attempts.';
  if (lower == 'powersaving off')
    return 'Disable repeater power-saving attempts.';
  if (lower.startsWith('password'))
    return 'Change the admin password used for remote access.';
  if (lower.startsWith('setperm'))
    return 'Set or remove ACL permissions for a companion public key.';
  if (lower == 'get acl')
    return 'Show the current access-control list. Serial only.';

  if (lower.startsWith('sensor get'))
    return 'Read one sensor or custom setting by key.';
  if (lower.startsWith('sensor set'))
    return 'Write one sensor or custom setting value.';
  if (lower.startsWith('sensor list'))
    return 'List sensor/custom settings, optionally starting at an index.';
  if (lower == 'gps') return 'Show GPS status, fix state and satellite count.';
  if (lower == 'gps on') return 'Enable GPS, if GPS support is compiled in.';
  if (lower == 'gps off') return 'Disable GPS, if GPS support is compiled in.';
  if (lower == 'gps sync') return 'Sync the node clock from the GPS provider.';
  if (lower == 'gps setloc')
    return 'Save the current GPS fix as the node location.';
  if (lower.startsWith('gps advert'))
    return 'Choose how location is advertised: none, share or saved prefs.';
  if (lower.startsWith('tempradio'))
    return 'Temporarily switch radio parameters for a fixed number of minutes.';

  if (lower == 'region' || lower == 'region tree')
    return 'Show the configured region hierarchy and flood flags.';
  if (lower == 'region save')
    return 'Persist region map, flags, home region and default scope to storage.';
  if (lower == 'region load')
    return 'Start interactive bulk region loading. Best used on direct serial.';
  if (lower == 'region list')
    return 'List regions; add allowed or denied to filter by flood forwarding state.';
  if (lower == 'region list allowed')
    return 'List regions that are allowed to forward flood traffic.';
  if (lower == 'region list denied')
    return 'List regions that are blocked from flood forwarding.';
  if (lower.startsWith('region get'))
    return 'Show one region, its parent and flood-forwarding flag.';
  if (lower.startsWith('region put'))
    return 'Create or move a region, optionally under a parent region.';
  if (lower.startsWith('region remove'))
    return 'Remove an empty region from the map.';
  if (lower.startsWith('region home'))
    return 'Show or set this node own most-specific home region.';
  if (lower.startsWith('region default'))
    return 'Show or set the default scope used for outgoing traffic.';
  if (lower.startsWith('region allowf'))
    return 'Allow flood forwarding for a region or wildcard.';
  if (lower.startsWith('region denyf'))
    return 'Block flood forwarding for a region or wildcard.';
  if (lower == 'regiondb' || lower == 'regiondb info')
    return 'Show metadata for the local Dutch region lookup table.';
  if (lower == 'regiondb provinces')
    return 'List Dutch province abbreviations and entry counts.';
  if (lower.startsWith('regiondb find'))
    return 'Find a Dutch location by name prefix and return its primary region code.';
  if (lower.startsWith('regiondb get'))
    return 'Read a Dutch region database entry by index, including all codes.';
  if (lower.startsWith('regiondb code'))
    return 'List Dutch region database entries that contain a region code.';

  if (lower.startsWith('get '))
    return _describeGetCommand(lower.substring(4).trim());
  if (lower.startsWith('set '))
    return _describeSetCommand(lower.substring(4).trim());

  return 'Stage this CLI command in the input box so you can review or edit it before sending.';
}

String _describeGetCommand(String key) {
  if (key.startsWith('radio'))
    return 'Read radio parameters as frequency, bandwidth, spreading factor and coding rate.';
  if (key == 'freq') return 'Read the configured LoRa frequency in MHz.';
  if (key == 'bw') return 'Read the configured LoRa bandwidth in kHz.';
  if (key == 'sf') return 'Read the configured spreading factor.';
  if (key == 'cr') return 'Read the configured coding rate.';
  if (key == 'tx') return 'Read the LoRa transmit power in dBm.';
  if (key == 'radio.rxgain')
    return 'Read boosted RX gain state on supported SX126x boards.';
  if (key == 'name') return 'Read the node display name.';
  if (key == 'lat') return 'Read the saved latitude.';
  if (key == 'lon') return 'Read the saved longitude.';
  if (key == 'public.key') return 'Read the node public key.';
  if (key == 'prv.key') return 'Read the private key. Serial only.';
  if (key == 'firmware' || key == 'version')
    return 'Read firmware version information.';
  if (key == 'role') return 'Read the node role reported by firmware.';
  if (key == 'repeat') return 'Read whether packet forwarding is enabled.';
  if (key == 'malformed.drop' || key == 'malformed')
    return 'Read malformed public-chat drop protection state.';
  if (key == 'path.hash.mode')
    return 'Read the path hash size used in this node adverts.';
  if (key == 'loop.detect')
    return 'Read loop detection mode for flood packets.';
  if (key == 'txdelay') return 'Read the flood transmit delay factor.';
  if (key == 'direct.txdelay')
    return 'Read the direct-message transmit delay factor.';
  if (key == 'rxdelay') return 'Read the receive processing delay base.';
  if (key == 'dutycycle') return 'Read the duty-cycle limit as a percentage.';
  if (key == 'af') return 'Read the older airtime-factor duty-cycle setting.';
  if (key == 'int.thresh') return 'Read the local interference threshold.';
  if (key == 'agc.reset.interval') return 'Read AGC reset interval in seconds.';
  if (key == 'multi.acks') return 'Read Multi-ACK support state.';
  if (key == 'advert.interval')
    return 'Read zero-hop advert interval in minutes.';
  if (key == 'flood.advert.interval')
    return 'Read flood advert interval in hours.';
  if (key == 'flood.max') return 'Read maximum flood hop count.';
  if (key == 'flood.advert.base')
    return 'Read flood-advert forwarding probability base.';
  if (key == 'flood.relay.prob')
    return 'Read flood relay probability from 0 to 255.';
  if (key == 'flood.dynamic.enable')
    return 'Read dense dynamic telemetry mode.';
  if (key == 'flood.node.delay' || key == 'node.delay')
    return 'Read stable per-node flood delay offset state.';
  if (key == 'flood.dup.suppress' || key == 'dup.suppress')
    return 'Read duplicate-hearing flood suppression state.';
  if (key == 'guest.password')
    return 'Read the guest password, when firmware exposes it.';
  if (key == 'allow.read.only')
    return 'Read whether read-only guests are allowed.';
  if (key == 'owner.info') return 'Read operator or owner information.';
  if (key == 'bridge.type')
    return 'Read the compiled bridge type: TCP, ESPNow, RS232 or none.';
  if (key == 'bridge.enabled')
    return 'Read whether bridge forwarding is enabled.';
  if (key == 'bridge.delay') return 'Read bridge delay in milliseconds.';
  if (key == 'bridge.source')
    return 'Read which bridge log stream is used as packet source.';
  if (key == 'bridge.baud') return 'Read RS232 bridge baud rate.';
  if (key == 'bridge.channel') return 'Read ESPNow WiFi channel.';
  if (key == 'bridge.secret') return 'Read ESPNow shared secret.';
  if (key == 'wifi.ssid') return 'Read saved WiFi SSID.';
  if (key == 'wifi.password')
    return 'Check saved WiFi password placeholder; firmware does not reveal it.';
  if (key == 'wifi.status')
    return 'Read TCP bridge WiFi/IP/RSSI/server connection status.';
  if (key == 'bridge.server') return 'Read TCP bridge server address.';
  if (key == 'bridge.port') return 'Read TCP bridge server port.';
  if (key == 'dense.stats')
    return 'Read dense mesh counters and congestion indicators.';
  if (key == 'spam.stats') return 'Read malformed/spam public-chat counters.';
  if (key == 'repeater.health' || key == 'repeater.status')
    return 'Read a compact repeater health and forwarding status summary.';
  if (key == 'power.stats') return 'Read power-saving runtime counters.';
  if (key == 'bootloader.ver')
    return 'Read bootloader version on supported nRF52 boards.';
  if (key == 'adc.multiplier')
    return 'Read battery ADC calibration multiplier.';
  if (key == 'pwrmgt.support')
    return 'Check whether nRF52 power management is compiled in.';
  if (key == 'pwrmgt.source')
    return 'Read whether the node booted on external power or battery.';
  if (key == 'pwrmgt.bootreason')
    return 'Read reset and shutdown reason on supported boards.';
  if (key == 'pwrmgt.bootmv')
    return 'Read boot voltage in millivolts on supported boards.';
  return 'Read the current value for this firmware configuration key.';
}

String _describeSetCommand(String expression) {
  final key = expression.split(RegExp(r'\s+')).first;
  if (key == 'radio')
    return 'Set frequency, bandwidth, spreading factor and coding rate together; reboot may be needed.';
  if (key == 'freq')
    return 'Set LoRa frequency in MHz. Direct serial only and reboot may be needed.';
  if (key == 'bw') return 'Set LoRa bandwidth in kHz.';
  if (key == 'sf') return 'Set LoRa spreading factor.';
  if (key == 'cr') return 'Set LoRa coding rate.';
  if (key == 'tx') return 'Set LoRa transmit power in dBm.';
  if (key == 'radio.rxgain')
    return 'Enable or disable boosted RX gain on supported SX126x boards.';
  if (key == 'name') return 'Set the node display name.';
  if (key == 'lat') return 'Set saved latitude in degrees.';
  if (key == 'lon') return 'Set saved longitude in degrees.';
  if (key == 'prv.key')
    return 'Replace the node private key. Reboot is required after a valid key is saved.';
  if (key == 'repeat') return 'Enable or disable packet forwarding.';
  if (key == 'malformed.drop' || key == 'malformed')
    return 'Enable or disable malformed public-chat drop protection.';
  if (key == 'path.hash.mode')
    return 'Set path hash size for this node adverts: 0, 1 or 2.';
  if (key == 'loop.detect')
    return 'Set flood loop detection mode: off, minimal, moderate or strict.';
  if (key == 'txdelay') return 'Set flood transmit delay factor.';
  if (key == 'direct.txdelay')
    return 'Set direct-message transmit delay factor.';
  if (key == 'rxdelay') return 'Set receive processing delay base.';
  if (key == 'dutycycle')
    return 'Set duty-cycle limit as a percentage from 1 to 100.';
  if (key == 'af')
    return 'Set older airtime factor; dutycycle is preferred on newer firmware.';
  if (key == 'int.thresh') return 'Set local interference threshold.';
  if (key == 'agc.reset.interval') return 'Set AGC reset interval in seconds.';
  if (key == 'multi.acks') return 'Enable or disable Multi-ACK support.';
  if (key == 'advert.interval')
    return 'Set zero-hop advert interval in minutes.';
  if (key == 'flood.advert.interval')
    return 'Set flood advert interval in hours.';
  if (key == 'flood.max') return 'Set maximum flood hop count.';
  if (key == 'flood.advert.base')
    return 'Set flood-advert forwarding probability base from 0 to 1.';
  if (key == 'flood.relay.prob')
    return 'Set flood relay probability from 0 to 255.';
  if (key == 'flood.dynamic.enable')
    return 'Enable or disable dense dynamic telemetry mode.';
  if (key == 'flood.node.delay' || key == 'node.delay')
    return 'Enable or disable stable per-node flood delay offset.';
  if (key == 'flood.dup.suppress' || key == 'dup.suppress')
    return 'Enable or disable duplicate-hearing flood suppression.';
  if (key == 'guest.password') return 'Set the guest password.';
  if (key == 'allow.read.only') return 'Allow or block read-only guest access.';
  if (key == 'owner.info')
    return 'Set operator or owner info; use vertical bars for line breaks.';
  if (key == 'bridge.enabled') return 'Enable or disable bridge forwarding.';
  if (key == 'bridge.delay') return 'Set bridge delay in milliseconds.';
  if (key == 'bridge.source')
    return 'Set bridge packet source direction, usually tx or rx.';
  if (key == 'bridge.baud') return 'Set RS232 bridge baud rate.';
  if (key == 'bridge.channel') return 'Set ESPNow WiFi channel from 1 to 14.';
  if (key == 'bridge.secret') return 'Set ESPNow shared secret.';
  if (key == 'wifi.ssid') return 'Set WiFi SSID for TCP bridge and online OTA.';
  if (key == 'wifi.password')
    return 'Set WiFi password for TCP bridge and online OTA.';
  if (key == 'bridge.server')
    return 'Set TCP bridge server hostname or IP address.';
  if (key == 'bridge.port') return 'Set TCP bridge server port.';
  if (key == 'adc.multiplier')
    return 'Set battery ADC calibration multiplier, if supported by the board.';
  return 'Set this firmware configuration key to the value shown in the command.';
}

class _CommandPalette extends StatelessWidget {
  const _CommandPalette({
    required this.mode,
    required this.onSelected,
  });

  final ConsoleMode mode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = _categoriesFor(mode);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 210),
        child: ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CommandCategoryView(
              category: category,
              onSelected: onSelected,
            );
          },
        ),
      ),
    );
  }

  static List<_CliCommandCategory> _categoriesFor(ConsoleMode mode) {
    return switch (mode) {
      ConsoleMode.companion => _companionCategories,
      ConsoleMode.repeater => _remoteCategories,
      ConsoleMode.directSerialRepeater => _serialCategories,
    };
  }
}

class _CommandCategoryView extends StatelessWidget {
  const _CommandCategoryView({
    required this.category,
    required this.onSelected,
  });

  final _CliCommandCategory category;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            category.title,
            style: TextStyle(
              color: cs.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final command in category.commands)
              ActionChip(
                visualDensity: VisualDensity.compact,
                label: Text(command.label),
                tooltip: command.tooltip,
                onPressed: () => onSelected(command.command),
              ),
          ],
        ),
      ],
    );
  }
}

const _companionCategories = <_CliCommandCategory>[
  _CliCommandCategory('Info', [
    _CliCommandAction('help', 'help'),
    _CliCommandAction('info', 'info'),
    _CliCommandAction('ver', 'ver'),
    _CliCommandAction('nodes', 'nodes'),
    _CliCommandAction('clock', 'clock'),
    _CliCommandAction('bat', 'bat'),
  ]),
  _CliCommandCategory('Stats', [
    _CliCommandAction('stats', 'stats'),
    _CliCommandAction('core', 'stats core'),
    _CliCommandAction('radio', 'stats radio'),
    _CliCommandAction('packets', 'stats packets'),
  ]),
  _CliCommandCategory('Get', [
    _CliCommandAction('name', 'get name'),
    _CliCommandAction('freq', 'get freq'),
    _CliCommandAction('bw', 'get bw'),
    _CliCommandAction('sf', 'get sf'),
    _CliCommandAction('cr', 'get cr'),
    _CliCommandAction('tx', 'get tx'),
    _CliCommandAction('public.key', 'get public.key'),
    _CliCommandAction('firmware', 'get firmware'),
    _CliCommandAction('repeat', 'get repeat'),
    _CliCommandAction('path.hash', 'get path.hash.mode'),
  ]),
  _CliCommandCategory('Set', [
    _CliCommandAction('name', 'set name '),
    _CliCommandAction('tx', 'set tx 20'),
    _CliCommandAction('freq', 'set freq 869.5'),
    _CliCommandAction('bw', 'set bw 250'),
    _CliCommandAction('sf', 'set sf 10'),
    _CliCommandAction('cr', 'set cr 5'),
    _CliCommandAction('repeat on', 'set repeat on'),
    _CliCommandAction('repeat off', 'set repeat off'),
  ]),
  _CliCommandCategory('System', [
    _CliCommandAction('reboot', 'reboot'),
  ]),
];

const _remoteCategories = <_CliCommandCategory>[
  _CliCommandCategory('System', [
    _CliCommandAction('help', 'help'),
    _CliCommandAction('ver', 'ver'),
    _CliCommandAction('board', 'board'),
    _CliCommandAction('clock', 'clock'),
    _CliCommandAction('clock reboot', 'clkreboot'),
    _CliCommandAction('reboot', 'reboot'),
    _CliCommandAction('poweroff', 'poweroff'),
    _CliCommandAction('start ota', 'start ota'),
    _CliCommandAction('ota check', 'ota.check'),
    _CliCommandAction('ota update', 'ota.update'),
  ]),
  _CliCommandCategory('Network', [
    _CliCommandAction('advert', 'advert'),
    _CliCommandAction('zero hop', 'advert.zerohop'),
    _CliCommandAction('discover', 'discover.neighbors'),
    _CliCommandAction('neighbors', 'neighbors'),
    _CliCommandAction('remove', 'neighbor.remove '),
  ]),
  _CliCommandCategory('Stats', [
    _CliCommandAction('core', 'stats-core'),
    _CliCommandAction('radio', 'stats-radio'),
    _CliCommandAction('packets', 'stats-packets'),
    _CliCommandAction('spam', 'get spam.stats'),
    _CliCommandAction('health', 'get repeater.health'),
    _CliCommandAction('status', 'get repeater.status'),
  ]),
  _CliCommandCategory('Config get', [
    _CliCommandAction('name', 'get name'),
    _CliCommandAction('radio', 'get radio'),
    _CliCommandAction('freq', 'get freq'),
    _CliCommandAction('bw', 'get bw'),
    _CliCommandAction('sf', 'get sf'),
    _CliCommandAction('cr', 'get cr'),
    _CliCommandAction('tx', 'get tx'),
    _CliCommandAction('af', 'get af'),
    _CliCommandAction('repeat', 'get repeat'),
    _CliCommandAction('role', 'get role'),
    _CliCommandAction('lat', 'get lat'),
    _CliCommandAction('lon', 'get lon'),
    _CliCommandAction('public.key', 'get public.key'),
    _CliCommandAction('wifi', 'get wifi.status'),
    _CliCommandAction('owner', 'get owner.info'),
    _CliCommandAction('guest pass', 'get guest.password'),
    _CliCommandAction('read only', 'get allow.read.only'),
  ]),
  _CliCommandCategory('Config set', [
    _CliCommandAction('name', 'set name '),
    _CliCommandAction('radio', 'set radio 869.5 250 10 5'),
    _CliCommandAction('tx', 'set tx 20'),
    _CliCommandAction('af', 'set af 1.0'),
    _CliCommandAction('repeat on', 'set repeat on'),
    _CliCommandAction('lat', 'set lat 52.0'),
    _CliCommandAction('lon', 'set lon 5.0'),
    _CliCommandAction('owner', 'set owner.info '),
    _CliCommandAction('bridge on', 'set bridge.enabled on'),
    _CliCommandAction('wifi ssid', 'set wifi.ssid '),
  ]),
  _CliCommandCategory('Routing get', [
    _CliCommandAction('advert', 'get advert.interval'),
    _CliCommandAction('flood advert', 'get flood.advert.interval'),
    _CliCommandAction('flood max', 'get flood.max'),
    _CliCommandAction('flood base', 'get flood.advert.base'),
    _CliCommandAction('flood prob', 'get flood.relay.prob'),
    _CliCommandAction('dynamic', 'get flood.dynamic.enable'),
    _CliCommandAction('path hash', 'get path.hash.mode'),
    _CliCommandAction('malformed', 'get malformed.drop'),
    _CliCommandAction('node delay', 'get flood.node.delay'),
    _CliCommandAction('dup suppress', 'get flood.dup.suppress'),
    _CliCommandAction('loop', 'get loop.detect'),
    _CliCommandAction('multi acks', 'get multi.acks'),
    _CliCommandAction('threshold', 'get int.thresh'),
    _CliCommandAction('rxdelay', 'get rxdelay'),
    _CliCommandAction('txdelay', 'get txdelay'),
    _CliCommandAction('direct delay', 'get direct.txdelay'),
    _CliCommandAction('dutycycle', 'get dutycycle'),
    _CliCommandAction('adc', 'get adc.multiplier'),
  ]),
  _CliCommandCategory('Bridge get', [
    _CliCommandAction('type', 'get bridge.type'),
    _CliCommandAction('enabled', 'get bridge.enabled'),
    _CliCommandAction('delay', 'get bridge.delay'),
    _CliCommandAction('source', 'get bridge.source'),
    _CliCommandAction('baud', 'get bridge.baud'),
    _CliCommandAction('channel', 'get bridge.channel'),
    _CliCommandAction('secret', 'get bridge.secret'),
    _CliCommandAction('ssid', 'get wifi.ssid'),
    _CliCommandAction('server', 'get bridge.server'),
    _CliCommandAction('port', 'get bridge.port'),
  ]),
  _CliCommandCategory('Advanced', [
    _CliCommandAction('sensor get', 'sensor get '),
    _CliCommandAction('sensor set', 'sensor set '),
    _CliCommandAction('sensor list', 'sensor list'),
    _CliCommandAction('region', 'region'),
    _CliCommandAction('region list', 'region list'),
    _CliCommandAction('region get', 'region get '),
    _CliCommandAction('region put', 'region put '),
    _CliCommandAction('region remove', 'region remove '),
    _CliCommandAction('region home', 'region home '),
    _CliCommandAction('region default', 'region default '),
    _CliCommandAction('region allowf', 'region allowf '),
    _CliCommandAction('region denyf', 'region denyf '),
    _CliCommandAction('region load', 'region load'),
    _CliCommandAction('region save', 'region save'),
    _CliCommandAction('regiondb info', 'regiondb info'),
    _CliCommandAction('regiondb provinces', 'regiondb provinces'),
    _CliCommandAction('regiondb find', 'regiondb find '),
    _CliCommandAction('regiondb get', 'regiondb get '),
    _CliCommandAction('regiondb code', 'regiondb code '),
    _CliCommandAction('gps', 'gps'),
    _CliCommandAction('gps on', 'gps on'),
    _CliCommandAction('gps sync', 'gps sync'),
    _CliCommandAction('gps setloc', 'gps setloc'),
    _CliCommandAction('gps advert', 'gps advert share'),
    _CliCommandAction('temp radio', 'tempradio 869.5 250 10 5 10'),
    _CliCommandAction('password', 'password '),
    _CliCommandAction('setperm', 'setperm '),
  ]),
];

const _serialCategories = <_CliCommandCategory>[
  _CliCommandCategory('Setup', [
    _CliCommandAction('wizard', 'config wizard'),
    _CliCommandAction('config', 'config'),
    _CliCommandAction('help', 'help'),
  ]),
  _CliCommandCategory('System', [
    _CliCommandAction('ver', 'ver'),
    _CliCommandAction('board', 'board'),
    _CliCommandAction('clock', 'clock'),
    _CliCommandAction('clock sync', 'clock sync'),
    _CliCommandAction('clock reboot', 'clkreboot'),
    _CliCommandAction('reboot', 'reboot'),
    _CliCommandAction('poweroff', 'poweroff'),
    _CliCommandAction('shutdown', 'shutdown'),
    _CliCommandAction('start ota', 'start ota'),
    _CliCommandAction('ota check', 'ota.check'),
    _CliCommandAction('ota update', 'ota.update'),
    _CliCommandAction('power save on', 'powersaving on'),
    _CliCommandAction('power save off', 'powersaving off'),
  ]),
  _CliCommandCategory('Network', [
    _CliCommandAction('advert', 'advert'),
    _CliCommandAction('zero hop', 'advert.zerohop'),
    _CliCommandAction('discover', 'discover.neighbors'),
    _CliCommandAction('neighbors', 'neighbors'),
    _CliCommandAction('remove', 'neighbor.remove '),
  ]),
  _CliCommandCategory('Stats', [
    _CliCommandAction('core', 'stats-core'),
    _CliCommandAction('radio', 'stats-radio'),
    _CliCommandAction('packets', 'stats-packets'),
    _CliCommandAction('clear stats', 'clear stats'),
    _CliCommandAction('clear dense', 'clear dense.stats'),
    _CliCommandAction('clear spam', 'clear spam.stats'),
    _CliCommandAction('clear power', 'clear power.stats'),
  ]),
  _CliCommandCategory('Logging', [
    _CliCommandAction('start', 'log start'),
    _CliCommandAction('stop', 'log stop'),
    _CliCommandAction('show', 'log'),
    _CliCommandAction('erase', 'log erase'),
  ]),
  _CliCommandCategory('Get', [
    _CliCommandAction('name', 'get name'),
    _CliCommandAction('radio', 'get radio'),
    _CliCommandAction('freq', 'get freq'),
    _CliCommandAction('bw', 'get bw'),
    _CliCommandAction('sf', 'get sf'),
    _CliCommandAction('cr', 'get cr'),
    _CliCommandAction('tx', 'get tx'),
    _CliCommandAction('af', 'get af'),
    _CliCommandAction('role', 'get role'),
    _CliCommandAction('repeat', 'get repeat'),
    _CliCommandAction('lat', 'get lat'),
    _CliCommandAction('lon', 'get lon'),
    _CliCommandAction('public.key', 'get public.key'),
    _CliCommandAction('prv.key', 'get prv.key'),
    _CliCommandAction('acl', 'get acl'),
    _CliCommandAction('wifi', 'get wifi.status'),
    _CliCommandAction('bridge', 'get bridge.enabled'),
    _CliCommandAction('bootloader', 'get bootloader.ver'),
    _CliCommandAction('spam', 'get spam.stats'),
    _CliCommandAction('health', 'get repeater.health'),
    _CliCommandAction('status', 'get repeater.status'),
  ]),
  _CliCommandCategory('Set', [
    _CliCommandAction('name', 'set name '),
    _CliCommandAction('radio', 'set radio 869.5 250 10 5'),
    _CliCommandAction('freq', 'set freq 869.5'),
    _CliCommandAction('bw', 'set bw 250'),
    _CliCommandAction('sf', 'set sf 10'),
    _CliCommandAction('cr', 'set cr 5'),
    _CliCommandAction('tx', 'set tx 20'),
    _CliCommandAction('af', 'set af 1.0'),
    _CliCommandAction('repeat on', 'set repeat on'),
    _CliCommandAction('repeat off', 'set repeat off'),
    _CliCommandAction('dutycycle', 'set dutycycle 10'),
    _CliCommandAction('rxgain on', 'set radio.rxgain on'),
    _CliCommandAction('rxgain off', 'set radio.rxgain off'),
    _CliCommandAction('lat', 'set lat 52.0'),
    _CliCommandAction('lon', 'set lon 5.0'),
    _CliCommandAction('owner', 'set owner.info '),
    _CliCommandAction('private key', 'set prv.key '),
  ]),
  _CliCommandCategory('Flood / routing', [
    _CliCommandAction('get advert', 'get advert.interval'),
    _CliCommandAction('get flood advert', 'get flood.advert.interval'),
    _CliCommandAction('get flood max', 'get flood.max'),
    _CliCommandAction('get flood base', 'get flood.advert.base'),
    _CliCommandAction('get flood prob', 'get flood.relay.prob'),
    _CliCommandAction('get dynamic', 'get flood.dynamic.enable'),
    _CliCommandAction('get node delay', 'get flood.node.delay'),
    _CliCommandAction('get dup suppress', 'get flood.dup.suppress'),
    _CliCommandAction('get malformed', 'get malformed.drop'),
    _CliCommandAction('get path hash', 'get path.hash.mode'),
    _CliCommandAction('get loop', 'get loop.detect'),
    _CliCommandAction('get multi', 'get multi.acks'),
    _CliCommandAction('get threshold', 'get int.thresh'),
    _CliCommandAction('get agc', 'get agc.reset.interval'),
    _CliCommandAction('get rxdelay', 'get rxdelay'),
    _CliCommandAction('get txdelay', 'get txdelay'),
    _CliCommandAction('get direct', 'get direct.txdelay'),
    _CliCommandAction('advert min', 'set advert.interval 60'),
    _CliCommandAction('flood advert', 'set flood.advert.interval 6'),
    _CliCommandAction('flood max', 'set flood.max 5'),
    _CliCommandAction('flood base', 'set flood.advert.base 0.5'),
    _CliCommandAction('flood prob', 'set flood.relay.prob 255'),
    _CliCommandAction('dynamic on', 'set flood.dynamic.enable on'),
    _CliCommandAction('dynamic off', 'set flood.dynamic.enable off'),
    _CliCommandAction('node delay on', 'set flood.node.delay on'),
    _CliCommandAction('node delay off', 'set flood.node.delay off'),
    _CliCommandAction('dup suppress on', 'set flood.dup.suppress on'),
    _CliCommandAction('dup suppress off', 'set flood.dup.suppress off'),
    _CliCommandAction('malformed on', 'set malformed.drop on'),
    _CliCommandAction('malformed off', 'set malformed.drop off'),
    _CliCommandAction('path hash', 'set path.hash.mode 1'),
    _CliCommandAction('loop strict', 'set loop.detect strict'),
    _CliCommandAction('multi acks', 'set multi.acks 1'),
    _CliCommandAction('threshold', 'set int.thresh 0'),
    _CliCommandAction('agc reset', 'set agc.reset.interval 60'),
    _CliCommandAction('rxdelay', 'set rxdelay 0'),
    _CliCommandAction('txdelay', 'set txdelay 1.0'),
    _CliCommandAction('direct delay', 'set direct.txdelay 1.0'),
  ]),
  _CliCommandCategory('Bridge', [
    _CliCommandAction('get type', 'get bridge.type'),
    _CliCommandAction('get enabled', 'get bridge.enabled'),
    _CliCommandAction('get delay', 'get bridge.delay'),
    _CliCommandAction('get source', 'get bridge.source'),
    _CliCommandAction('get baud', 'get bridge.baud'),
    _CliCommandAction('get channel', 'get bridge.channel'),
    _CliCommandAction('get secret', 'get bridge.secret'),
    _CliCommandAction('get ssid', 'get wifi.ssid'),
    _CliCommandAction('get password', 'get wifi.password'),
    _CliCommandAction('get server', 'get bridge.server'),
    _CliCommandAction('get port', 'get bridge.port'),
    _CliCommandAction('bridge on', 'set bridge.enabled on'),
    _CliCommandAction('bridge off', 'set bridge.enabled off'),
    _CliCommandAction('delay', 'set bridge.delay 1000'),
    _CliCommandAction('source tx', 'set bridge.source tx'),
    _CliCommandAction('source rx', 'set bridge.source rx'),
    _CliCommandAction('wifi ssid', 'set wifi.ssid '),
    _CliCommandAction('wifi pass', 'set wifi.password '),
    _CliCommandAction('server', 'set bridge.server '),
    _CliCommandAction('port', 'set bridge.port 5000'),
    _CliCommandAction('baud', 'set bridge.baud 115200'),
    _CliCommandAction('channel', 'set bridge.channel 6'),
    _CliCommandAction('secret', 'set bridge.secret '),
  ]),
  _CliCommandCategory('Sensors / GPS / regions', [
    _CliCommandAction('sensor get', 'sensor get '),
    _CliCommandAction('sensor set', 'sensor set '),
    _CliCommandAction('sensor list', 'sensor list'),
    _CliCommandAction('sensor list start', 'sensor list '),
    _CliCommandAction('gps', 'gps'),
    _CliCommandAction('gps on', 'gps on'),
    _CliCommandAction('gps off', 'gps off'),
    _CliCommandAction('gps sync', 'gps sync'),
    _CliCommandAction('gps loc', 'gps setloc'),
    _CliCommandAction('gps advert none', 'gps advert none'),
    _CliCommandAction('gps advert share', 'gps advert share'),
    _CliCommandAction('gps advert prefs', 'gps advert prefs'),
    _CliCommandAction('region', 'region'),
    _CliCommandAction('region list', 'region list'),
    _CliCommandAction('region allowed', 'region list allowed'),
    _CliCommandAction('region denied', 'region list denied'),
    _CliCommandAction('region get', 'region get '),
    _CliCommandAction('region put', 'region put '),
    _CliCommandAction('region remove', 'region remove '),
    _CliCommandAction('region home', 'region home '),
    _CliCommandAction('region default', 'region default '),
    _CliCommandAction('region allowf', 'region allowf '),
    _CliCommandAction('region denyf', 'region denyf '),
    _CliCommandAction('region save', 'region save'),
    _CliCommandAction('region load', 'region load'),
    _CliCommandAction('regiondb info', 'regiondb info'),
    _CliCommandAction('regiondb provinces', 'regiondb provinces'),
    _CliCommandAction('regiondb find', 'regiondb find '),
    _CliCommandAction('regiondb get', 'regiondb get '),
    _CliCommandAction('regiondb code', 'regiondb code '),
  ]),
  _CliCommandCategory('Access', [
    _CliCommandAction('get guest', 'get guest.password'),
    _CliCommandAction('get read only', 'get allow.read.only'),
    _CliCommandAction('password', 'password '),
    _CliCommandAction('setperm', 'setperm '),
    _CliCommandAction('guest pass', 'set guest.password '),
    _CliCommandAction('read only on', 'set allow.read.only on'),
    _CliCommandAction('read only off', 'set allow.read.only off'),
  ]),
  _CliCommandCategory('Hardware specific', [
    _CliCommandAction('get dense', 'get dense.stats'),
    _CliCommandAction('get power', 'get power.stats'),
    _CliCommandAction('get adc', 'get adc.multiplier'),
    _CliCommandAction('set adc', 'set adc.multiplier 1.0'),
    _CliCommandAction('pwr support', 'get pwrmgt.support'),
    _CliCommandAction('pwr source', 'get pwrmgt.source'),
    _CliCommandAction('boot reason', 'get pwrmgt.bootreason'),
    _CliCommandAction('boot mV', 'get pwrmgt.bootmv'),
  ]),
];

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
    this.onWizard,
  });

  final List<MeshDevice> devices;
  final MeshDevice? selected;
  final bool busy;
  final VoidCallback onScan;
  final ValueChanged<MeshDevice> onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onConfig;
  final VoidCallback? onWizard;

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
            if (onWizard != null)
              FilledButton.icon(
                  onPressed: busy ? null : onWizard,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Wizard')),
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
