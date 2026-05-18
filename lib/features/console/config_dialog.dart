import 'package:flutter/material.dart';

// ─── Parameter definitions ────────────────────────────────────

class _Param {
  const _Param(this.key, this.label,
      {this.unit = '', this.options, this.isSecret = false, this.requiresReboot = false});
  final String key;
  final String label;
  final String unit;
  final List<String>? options;
  final bool isSecret;
  final bool requiresReboot;
  bool get isDropdown => options != null;
}

class _Section {
  const _Section(this.title, this.params);
  final String title;
  final List<_Param> params;
}

const _kSections = <_Section>[
  _Section('Identity', <_Param>[
    _Param('name',       'Node name'),
    _Param('owner.info', 'Owner info'),
    _Param('lat',        'Latitude',  unit: '°'),
    _Param('lon',        'Longitude', unit: '°'),
  ]),
  _Section('Radio', <_Param>[
    _Param('freq',         'Frequency',         unit: 'MHz'),
    _Param('bw',           'Bandwidth',         unit: 'kHz'),
    _Param('sf',           'Spreading factor',  options: ['5','6','7','8','9','10','11','12']),
    _Param('cr',           'Coding rate',       options: ['5','6','7','8']),
    _Param('tx',           'TX power',          unit: 'dBm'),
    _Param('af',           'Atten. factor'),
    _Param('repeat',       'Packet forwarding', options: ['on','off']),
    _Param('dutycycle',    'Duty cycle',        unit: '%'),
    _Param('radio.rxgain', 'RX gain',           options: ['on','off']),
  ]),
  _Section('Advertising', <_Param>[
    _Param('advert.interval',       'Advert interval',       unit: 'min'),
    _Param('flood.advert.interval', 'Flood advert interval', unit: 'h'),
  ]),
  _Section('Flood / Routing', <_Param>[
    _Param('flood.max',            'Flood max hops'),
    _Param('flood.advert.base',    'Flood advert base'),
    _Param('flood.relay.prob',     'Flood relay prob',       unit: '0–255'),
    _Param('flood.dynamic.enable', 'Flood dynamic enable',   options: ['on','off']),
    _Param('path.hash.mode',       'Path hash mode',         options: ['0','1','2']),
    _Param('loop.detect',          'Loop detect',            options: ['off','minimal','moderate','strict']),
    _Param('multi.acks',           'Multi-ACKs',             options: ['0','1']),
    _Param('int.thresh',           'Interference threshold'),
    _Param('rxdelay',              'RX delay',               unit: 'ms'),
    _Param('txdelay',              'TX delay factor'),
    _Param('direct.txdelay',       'Direct TX delay factor'),
    _Param('agc.reset.interval',   'AGC reset interval',     unit: 's'),
  ]),
  _Section('Access', <_Param>[
    _Param('guest.password',  'Guest password'),
    _Param('allow.read.only', 'Allow read-only', options: ['on','off']),
  ]),
  _Section('TCP Bridge', <_Param>[
    _Param('bridge.enabled', 'Bridge enabled',   options: ['on','off'], requiresReboot: true),
    _Param('wifi.ssid',      'WiFi SSID',        requiresReboot: true),
    _Param('wifi.password',  'WiFi password',    isSecret: true, requiresReboot: true),
    _Param('bridge.server',  'Server address',   requiresReboot: true),
    _Param('bridge.port',    'Server port',      requiresReboot: true),
    _Param('bridge.delay',   'Bridge delay',     unit: 'ms', requiresReboot: true),
  ]),
  _Section('ESPNow Bridge', <_Param>[
    _Param('bridge.source',  'Source direction', options: ['tx','rx'], requiresReboot: true),
    _Param('bridge.baud',    'Baud rate',        requiresReboot: true),
    _Param('bridge.channel', 'WiFi channel',     requiresReboot: true),
    _Param('bridge.secret',  'Shared secret',    isSecret: true, requiresReboot: true),
  ]),
];

// ─── Mutable state per parameter ─────────────────────────────

class _Entry {
  _Entry(this.param) : controller = TextEditingController();

  final _Param param;
  final TextEditingController controller;
  String? original;
  String? dropdownValue;

  void init(String? value) {
    original = value;
    if (param.isDropdown) {
      dropdownValue = (param.options!.contains(value)) ? value : null;
    } else {
      controller.text = value ?? '';
    }
  }

  bool get changed {
    if (param.isDropdown) return dropdownValue != original;
    return controller.text.trim() != (original ?? '');
  }

  String get current =>
      param.isDropdown ? (dropdownValue ?? '') : controller.text.trim();

  void dispose() => controller.dispose();
}

// ─── Dialog ───────────────────────────────────────────────────

enum _Phase { loading, editing, applying, done }

class SerialConfigDialog extends StatefulWidget {
  const SerialConfigDialog({
    super.key,
    required this.deviceName,
    required this.queryParam,
    required this.setParam,
    required this.sendCommand,
  });

  final String deviceName;

  /// Sends `get <key>` and returns the value string, or null on timeout.
  final Future<String?> Function(String key) queryParam;

  /// Sends `set <key> <value>` and returns the device response.
  final Future<String?> Function(String key, String value) setParam;

  /// Sends a raw command (e.g. `reboot`) without waiting for a response.
  final Future<void> Function(String command) sendCommand;

  @override
  State<SerialConfigDialog> createState() => _SerialConfigDialogState();
}

class _SerialConfigDialogState extends State<SerialConfigDialog> {
  late final List<_Entry> _entries;
  late final Map<String, _Entry> _entryMap;
  _Phase _phase = _Phase.loading;
  int _loadedCount = 0;
  final _results = <String, bool>{}; // key → success
  int _changedCount = 0;
  bool _rebootNeeded = false;
  // Firmware returns freq/bw/sf/cr together via `get radio` — cached here.
  Map<String, String>? _radioCache;

  @override
  void initState() {
    super.initState();
    _entries = [];
    _entryMap = {};
    for (final section in _kSections) {
      for (final param in section.params) {
        final entry = _Entry(param);
        _entries.add(entry);
        _entryMap[param.key] = entry;
      }
    }
    _loadAll();
  }

  @override
  void dispose() {
    for (final e in _entries) { e.dispose(); }
    super.dispose();
  }

  static const _radioKeys = {'freq', 'bw', 'sf', 'cr'};

  Future<void> _loadAll() async {
    for (final entry in _entries) {
      if (!mounted) return;
      final String? value;
      if (entry.param.isSecret) {
        // Never fetch passwords from the device.
        value = null;
      } else if (_radioKeys.contains(entry.param.key)) {
        // Firmware has no individual get for bw/sf/cr — use `get radio`
        // which returns "freq,bw,sf,cr" in one response.
        if (_radioCache == null) {
          final raw = await widget.queryParam('radio');
          if (!mounted) return;
          if (raw != null) {
            final parts = raw.split(',');
            if (parts.length >= 4) {
              _radioCache = {
                'freq': parts[0].trim(),
                'bw':   parts[1].trim(),
                'sf':   parts[2].trim(),
                'cr':   parts[3].trim(),
              };
            }
          }
          _radioCache ??= {};
        }
        value = _radioCache![entry.param.key];
      } else {
        value = await widget.queryParam(entry.param.key);
      }
      if (!mounted) return;
      setState(() {
        entry.init(value);
        _loadedCount++;
        if (_loadedCount == _entries.length) _phase = _Phase.editing;
      });
    }
  }

  Future<void> _apply() async {
    final toApply = _entries
        .where((e) => e.changed && e.current.isNotEmpty)
        .toList();
    if (toApply.isEmpty) {
      setState(() { _changedCount = 0; _phase = _Phase.done; });
      return;
    }
    setState(() { _phase = _Phase.applying; _changedCount = toApply.length; });
    for (final entry in toApply) {
      if (!mounted) return;
      final response = await widget.setParam(entry.param.key, entry.current);
      if (!mounted) return;
      final ok = response == null ||
          !response.toLowerCase().contains('error');
      setState(() {
        _results[entry.param.key] = ok;
        if (ok && entry.param.requiresReboot) _rebootNeeded = true;
      });
    }
    if (mounted) setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(children: [
                const Icon(Icons.tune),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Configure  ${widget.deviceName}',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(child: _buildBody()),

            // ── Footer ───────────────────────────────────────
            _buildFooter(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ColorScheme cs) {
    return switch (_phase) {
      _Phase.loading => const SizedBox.shrink(),

      _Phase.applying => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Applying changes…'),
          ]),
        ),

      _Phase.editing => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Apply changes'),
            ),
          ]),
        ),

      _Phase.done => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_rebootNeeded)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(children: [
                  Icon(Icons.restart_alt, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WiFi / bridge settings changed — device needs to reboot before they take effect.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Text(
                  '$_changedCount change${_changedCount == 1 ? '' : 's'} applied',
                  style: TextStyle(color: cs.secondary),
                ),
                const Spacer(),
                if (_rebootNeeded) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await widget.sendCommand('reboot');
                      nav.pop();
                    },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Reboot now'),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ]),
            ),
          ],
        ),
    };
  }

  Widget _buildBody() {
    if (_phase == _Phase.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Fetching parameters…  $_loadedCount / ${_entries.length}'),
          ],
        ),
      );
    }

    final rows = <Widget>[];
    for (final section in _kSections) {
      rows.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
        child: Text(
          section.title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
              letterSpacing: 0.6),
        ),
      ));
      for (final param in section.params) {
        rows.add(_buildRow(_entryMap[param.key]!));
      }
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: rows,
    );
  }

  Widget _buildRow(_Entry entry) {
    final key = entry.param.key;
    final hasResult = _results.containsKey(key);
    final ok = _results[key] ?? false;
    final editable = _phase == _Phase.editing;

    Color? bg;
    if (hasResult) {
      bg = (ok ? Colors.green : Colors.red).withValues(alpha: 0.08);
    } else if (entry.changed) {
      bg = Colors.orange.withValues(alpha: 0.07);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.param.label,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text(key,
                      style: const TextStyle(fontSize: 11,
                          color: Colors.grey)),
                ],
              ),
            ),
            Expanded(child: _buildInput(entry, editable)),
            SizedBox(
              width: 28,
              child: hasResult
                  ? Icon(
                      ok ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: ok ? Colors.green : Colors.red,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(_Entry entry, bool editable) {
    if (entry.param.isDropdown) {
      return DropdownButton<String>(
        value: entry.dropdownValue,
        isExpanded: true,
        isDense: true,
        items: [
          for (final opt in entry.param.options!)
            DropdownMenuItem(value: opt, child: Text(opt)),
        ],
        onChanged: editable
            ? (v) => setState(() => entry.dropdownValue = v)
            : null,
      );
    }
    return TextFormField(
      controller: entry.controller,
      enabled: editable,
      obscureText: entry.param.isSecret,
      decoration: InputDecoration(
        isDense: true,
        hintText: entry.param.isSecret ? '(leave blank to keep unchanged)' : null,
        hintStyle: const TextStyle(fontSize: 11),
        suffix: entry.param.unit.isNotEmpty
            ? Text(entry.param.unit,
                style: const TextStyle(fontSize: 11, color: Colors.grey))
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
