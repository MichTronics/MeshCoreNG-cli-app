import 'package:flutter/material.dart';

import '../../core/regions/dutch_region_db.dart';
import '../../shared/responsive.dart';

// ─── Parameter definitions ────────────────────────────────────

class _Param {
  const _Param(this.key, this.label,
      {this.unit = '',
      this.options,
      this.isSecret = false,
      this.requiresReboot = false});
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
    _Param('name', 'Node name'),
    _Param('owner.info', 'Owner info'),
    _Param('lat', 'Latitude', unit: '°'),
    _Param('lon', 'Longitude', unit: '°'),
  ]),
  _Section('Radio', <_Param>[
    _Param('freq', 'Frequency', unit: 'MHz'),
    _Param('bw', 'Bandwidth', unit: 'kHz'),
    _Param('sf', 'Spreading factor',
        options: ['5', '6', '7', '8', '9', '10', '11', '12']),
    _Param('cr', 'Coding rate', options: ['5', '6', '7', '8']),
    _Param('tx', 'TX power', unit: 'dBm'),
    _Param('af', 'Atten. factor'),
    _Param('repeat', 'Packet forwarding', options: ['on', 'off']),
    _Param('dutycycle', 'Duty cycle', unit: '%'),
    _Param('radio.rxgain', 'RX gain', options: ['on', 'off']),
  ]),
  _Section('Advertising', <_Param>[
    _Param('advert.interval', 'Advert interval', unit: 'min'),
    _Param('flood.advert.interval', 'Flood advert interval', unit: 'h'),
  ]),
  _Section('Flood / Routing', <_Param>[
    _Param('flood.max', 'Flood max hops'),
    _Param('flood.advert.base', 'Flood advert base'),
    _Param('flood.relay.prob', 'Flood relay prob', unit: '0–255'),
    _Param('flood.dynamic.enable', 'Flood dynamic enable',
        options: ['on', 'off']),
    _Param('flood.node.delay', 'Stable node delay', options: ['on', 'off']),
    _Param('flood.dup.suppress', 'Duplicate suppression',
        options: ['on', 'off']),
    _Param('malformed.drop', 'Malformed chat drop', options: ['on', 'off']),
    _Param('path.hash.mode', 'Path hash mode', options: ['0', '1', '2']),
    _Param('loop.detect', 'Loop detect',
        options: ['off', 'minimal', 'moderate', 'strict']),
    _Param('multi.acks', 'Multi-ACKs', options: ['0', '1']),
    _Param('int.thresh', 'Interference threshold'),
    _Param('rxdelay', 'RX delay', unit: 'ms'),
    _Param('txdelay', 'TX delay factor'),
    _Param('direct.txdelay', 'Direct TX delay factor'),
    _Param('agc.reset.interval', 'AGC reset interval', unit: 's'),
  ]),
  _Section('Access', <_Param>[
    _Param('admin.password', 'Admin password', isSecret: true),
    _Param('guest.password', 'Guest password'),
    _Param('allow.read.only', 'Allow read-only', options: ['on', 'off']),
  ]),
  _Section('TCP Bridge', <_Param>[
    _Param('bridge.enabled', 'Bridge enabled', options: ['on', 'off']),
    _Param('wifi.ssid', 'WiFi SSID', requiresReboot: true),
    _Param('wifi.password', 'WiFi password',
        isSecret: true, requiresReboot: true),
    _Param('bridge.server', 'Server address'),
    _Param('bridge.port', 'Server port'),
    _Param('bridge.password', 'Bridge auth password', isSecret: true),
    _Param('bridge.rf', 'Forward on RF', options: ['on', 'off']),
    _Param('bridge.delay', 'Bridge delay', unit: 'ms'),
  ]),
  _Section('ESPNow Bridge', <_Param>[
    _Param('bridge.source', 'Source direction',
        options: ['tx', 'rx'], requiresReboot: true),
    _Param('bridge.baud', 'Baud rate', requiresReboot: true),
    _Param('bridge.channel', 'WiFi channel', requiresReboot: true),
    _Param('bridge.secret', 'Shared secret',
        isSecret: true, requiresReboot: true),
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

final Map<String, _Param> _paramsByKey = {
  for (final section in _kSections)
    for (final param in section.params) param.key: param,
};

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

class SerialConfigWizardDialog extends StatefulWidget {
  const SerialConfigWizardDialog({
    super.key,
    required this.deviceName,
    required this.queryParam,
    required this.queryCommand,
    required this.setParam,
    required this.sendCommand,
  });

  final String deviceName;
  final Future<String?> Function(String key) queryParam;
  final Future<String?> Function(String command) queryCommand;
  final Future<String?> Function(String key, String value) setParam;
  final Future<void> Function(String command) sendCommand;

  @override
  State<SerialConfigWizardDialog> createState() =>
      _SerialConfigWizardDialogState();
}

class _WizardStep {
  const _WizardStep(this.title, this.keys);

  final String title;
  final List<String> keys;
}

const _wizardSteps = <_WizardStep>[
  _WizardStep('Identity', ['name', 'owner.info', 'lat', 'lon']),
  _WizardStep('Radio', ['freq', 'bw', 'sf', 'cr', 'tx', 'repeat']),
  _WizardStep('Flood / routing', [
    'advert.interval',
    'flood.advert.interval',
    'flood.max',
    'flood.relay.prob',
    'path.hash.mode',
    'flood.node.delay',
    'flood.dup.suppress',
    'malformed.drop',
  ]),
  _WizardStep('Access', ['admin.password', 'guest.password', 'allow.read.only']),
  _WizardStep('Bridge', [
    'bridge.enabled',
    'wifi.ssid',
    'wifi.password',
    'bridge.server',
    'bridge.port',
  ]),
  _WizardStep('Regions', []),
];

const _kGermanRegionPreset = <String>[
  'de',
  'de-bw de',
  'de-by de',
  'de-be de',
  'de-bb de',
  'de-hb de',
  'de-hh de',
  'de-he de',
  'de-mv de',
  'de-ni de',
  'de-nw de',
  'de-rp de',
  'de-sl de',
  'de-sn de',
  'de-st de',
  'de-sh de',
  'de-th de',
];

enum _WizardPhase { loading, editing, applying, done }

class _SerialConfigWizardDialogState extends State<SerialConfigWizardDialog> {
  late final Map<String, _Entry> _entries;
  final _regionHomeController = TextEditingController();
  final _regionDefaultController = TextEditingController();
  final _regionAllowedController = TextEditingController();
  final _regionDeniedController = TextEditingController();
  final _regionPutController = TextEditingController();
  final _regionLookupController = TextEditingController();
  _WizardPhase _phase = _WizardPhase.loading;
  int _step = 0;
  int _loadedCount = 0;
  int _changedCount = 0;
  bool _rebootNeeded = false;
  final _results = <String, bool>{};
  Map<String, String>? _radioCache;
  String? _originalRegionHome;
  String? _originalRegionDefault;
  String? _originalRegionAllowed;
  String? _originalRegionDenied;
  String? _regionTree;
  String? _regionDbInfo;
  String? _regionDbProvinces;
  String? _regionLookupResult;
  String? _regionLookupCode;
  bool _regionBusy = false;

  @override
  void initState() {
    super.initState();
    _entries = {
      for (final step in _wizardSteps)
        for (final key in step.keys) key: _Entry(_paramsByKey[key]!),
    };
    _loadAll();
  }

  @override
  void dispose() {
    for (final entry in _entries.values) {
      entry.dispose();
    }
    _regionHomeController.dispose();
    _regionDefaultController.dispose();
    _regionAllowedController.dispose();
    _regionDeniedController.dispose();
    _regionPutController.dispose();
    _regionLookupController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    for (final entry in _entries.values) {
      if (!mounted) return;
      final String? value;
      if (entry.param.isSecret) {
        value = null;
      } else if (_SerialConfigDialogState._radioKeys
          .contains(entry.param.key)) {
        if (_radioCache == null) {
          final raw = await widget.queryParam('radio');
          if (!mounted) return;
          if (raw != null) {
            final parts = raw.split(',');
            if (parts.length >= 4) {
              _radioCache = {
                'freq': parts[0].trim(),
                'bw': parts[1].trim(),
                'sf': parts[2].trim(),
                'cr': parts[3].trim(),
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
      });
    }
    await _loadRegionState();
    if (mounted) setState(() => _phase = _WizardPhase.editing);
  }

  Future<void> _loadRegionState() async {
    final home = await widget.queryCommand('region home');
    if (!mounted) return;
    final def = await widget.queryCommand('region default');
    if (!mounted) return;
    final allowed = await widget.queryCommand('region list allowed');
    if (!mounted) return;
    final denied = await widget.queryCommand('region list denied');
    if (!mounted) return;
    final tree = await widget.queryCommand('region tree');
    if (!mounted) return;
    final dbInfo = DutchRegionDb.info();
    final provinces = DutchRegionDb.provinces();

    final homeValue = _parseRegionValue(home, 'home is');
    final defaultValue = _parseRegionValue(def, 'default scope is');
    final allowedValue = _normalizeRegionList(allowed);
    final deniedValue = _normalizeRegionList(denied);
    setState(() {
      _originalRegionHome = homeValue;
      _originalRegionDefault = defaultValue;
      _originalRegionAllowed = allowedValue;
      _originalRegionDenied = deniedValue;
      _regionHomeController.text = homeValue;
      _regionDefaultController.text = defaultValue;
      _regionAllowedController.text = allowedValue;
      _regionDeniedController.text = deniedValue;
      _regionTree = tree;
      _regionDbInfo = dbInfo;
      _regionDbProvinces = provinces;
    });
  }

  String _parseRegionValue(String? raw, String marker) {
    final value = raw?.trim() ?? '';
    final index = value.indexOf(marker);
    if (index >= 0) return value.substring(index + marker.length).trim();
    return value.startsWith('Err') ? '' : value;
  }

  String _normalizeRegionList(String? raw) {
    final value = raw?.trim() ?? '';
    if (value == '-none-' || value.startsWith('Err')) return '';
    return value.replaceAll(',', '\n').trim();
  }

  bool get _regionsChanged {
    return _regionHomeController.text.trim() != (_originalRegionHome ?? '') ||
        _regionDefaultController.text.trim() !=
            (_originalRegionDefault ?? '') ||
        _regionAllowedController.text.trim() !=
            (_originalRegionAllowed ?? '') ||
        _regionDeniedController.text.trim() != (_originalRegionDenied ?? '') ||
        _regionPutController.text.trim().isNotEmpty;
  }

  List<String> _regionNames(String text) {
    return text
        .split(RegExp(r'[\s,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _findRegion() async {
    final prefix = _regionLookupController.text.trim();
    if (prefix.isEmpty || _regionBusy) return;
    setState(() {
      _regionBusy = true;
      _regionLookupResult = null;
      _regionLookupCode = null;
    });
    try {
      final result = DutchRegionDb.find(prefix);
      if (!mounted) return;
      setState(() {
        _regionLookupResult = result;
        _regionLookupCode = _parseRegionDbPrimaryCode(result);
      });
    } finally {
      if (mounted) setState(() => _regionBusy = false);
    }
  }

  String? _parseRegionDbPrimaryCode(String? result) {
    if (result == null || result.startsWith('Err')) return null;
    final match = RegExp(r'\]\s+([^\s,]+)').firstMatch(result);
    return match?.group(1);
  }

  void _useLookupCode() {
    final code = _regionLookupCode;
    if (code == null) return;
    setState(() {
      _regionHomeController.text = code;
      _regionDefaultController.text = code;
      final allowed = _regionNames(_regionAllowedController.text).toSet()
        ..add(code);
      _regionAllowedController.text = allowed.join('\n');
    });
  }

  void _addGermanRegionPreset() {
    setState(() {
      final existingPut = _regionPutController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final existingPutSet = existingPut.toSet();
      for (final line in _kGermanRegionPreset) {
        if (existingPutSet.add(line)) existingPut.add(line);
      }
      _regionPutController.text = existingPut.join('\n');

      final allowed = _regionNames(_regionAllowedController.text).toSet()
        ..add('de');
      _regionAllowedController.text = allowed.join('\n');
    });
  }

  Future<int> _applyRegionChanges() async {
    if (!_regionsChanged) return 0;
    var applied = 0;
    final commands = <String>[];
    for (final line in _regionPutController.text.split('\n')) {
      final value = line.trim();
      if (value.isNotEmpty) commands.add('region put $value');
    }
    for (final name in _regionNames(_regionAllowedController.text)) {
      commands.add('region allowf $name');
    }
    for (final name in _regionNames(_regionDeniedController.text)) {
      commands.add('region denyf $name');
    }
    final home = _regionHomeController.text.trim();
    if (home.isNotEmpty && home != (_originalRegionHome ?? '')) {
      commands.add('region home $home');
    }
    final def = _regionDefaultController.text.trim();
    if (def != (_originalRegionDefault ?? '')) {
      commands.add('region default ${def.isEmpty ? '<null>' : def}');
    }
    if (commands.isNotEmpty) commands.add('region save');

    for (final command in commands) {
      if (!mounted) return applied;
      final response = await widget.queryCommand(command);
      if (!mounted) return applied;
      final ok = response == null ||
          (!response.toLowerCase().startsWith('err') &&
              !response.toLowerCase().contains('error'));
      setState(() => _results[command] = ok);
      applied++;
    }
    return applied;
  }

  Future<void> _apply() async {
    final toApply = _entries.values
        .where((e) => e.changed && e.current.isNotEmpty)
        .toList();
    if (toApply.isEmpty && !_regionsChanged) {
      setState(() {
        _changedCount = 0;
        _phase = _WizardPhase.done;
      });
      return;
    }

    setState(() {
      _phase = _WizardPhase.applying;
      _changedCount = toApply.length;
    });

    for (final entry in toApply) {
      if (!mounted) return;
      final response = await widget.setParam(entry.param.key, entry.current);
      if (!mounted) return;
      final ok = response == null || !response.toLowerCase().contains('error');
      setState(() {
        _results[entry.param.key] = ok;
        if (ok && entry.param.requiresReboot) _rebootNeeded = true;
      });
    }
    final regionChanges = await _applyRegionChanges();

    if (mounted) {
      setState(() {
        _changedCount += regionChanges;
        _phase = _WizardPhase.done;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Dialog(
        insetPadding: EdgeInsets.all(MeshResponsive.pagePadding(context)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.sizeOf(context).width < MeshResponsive.mobileMax
                    ? MediaQuery.sizeOf(context).width
                    : 680,
            maxHeight: (MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    MeshResponsive.pagePadding(context) * 2)
                .clamp(360.0, 760.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(children: [
                  const Icon(Icons.auto_fix_high),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Setup wizard: ${widget.deviceName}',
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
              Expanded(child: _buildBody()),
              _buildFooter(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_phase == _WizardPhase.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading setup values... $_loadedCount / ${_entries.length}'),
          ],
        ),
      );
    }

    if (_phase == _WizardPhase.applying) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Applying wizard changes...'),
          ],
        ),
      );
    }

    if (_phase == _WizardPhase.done) {
      final failed = _results.entries.where((e) => !e.value).length;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                failed == 0 ? Icons.check_circle_outline : Icons.error_outline,
                size: 42,
                color: failed == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                failed == 0
                    ? 'Wizard changes applied'
                    : 'Wizard completed with $failed failed change${failed == 1 ? '' : 's'}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Stepper(
      currentStep: _step,
      type: StepperType.vertical,
      controlsBuilder: (_, __) => const SizedBox.shrink(),
      onStepTapped: (index) => setState(() => _step = index),
      steps: [
        for (var i = 0; i < _wizardSteps.length; i++)
          Step(
            title: Text(_wizardSteps[i].title),
            isActive: i == _step,
            state: i < _step ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                if (_wizardSteps[i].title == 'Regions')
                  _RegionWizardFields(
                    homeController: _regionHomeController,
                    defaultController: _regionDefaultController,
                    allowedController: _regionAllowedController,
                    deniedController: _regionDeniedController,
                    putController: _regionPutController,
                    lookupController: _regionLookupController,
                    dbInfo: _regionDbInfo,
                    dbProvinces: _regionDbProvinces,
                    tree: _regionTree,
                    lookupResult: _regionLookupResult,
                    lookupCode: _regionLookupCode,
                    busy: _regionBusy,
                    onChanged: () => setState(() {}),
                    onFind: _findRegion,
                    onUseLookup: _useLookupCode,
                    onAddGermanPreset: _addGermanRegionPreset,
                  )
                else
                  for (final key in _wizardSteps[i].keys)
                    _WizardField(
                      entry: _entries[key]!,
                      result: _results[key],
                      onChanged: () => setState(() {}),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme cs) {
    if (_phase == _WizardPhase.loading || _phase == _WizardPhase.applying) {
      return const SizedBox.shrink();
    }

    if (_phase == _WizardPhase.done) {
      return Column(
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
                    'Bridge or WiFi settings changed; reboot before they take effect.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ]),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: MeshResponsive.gap(context),
              runSpacing: MeshResponsive.gap(context),
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$_changedCount change${_changedCount == 1 ? '' : 's'} applied',
                  style: TextStyle(color: cs.secondary),
                ),
                if (_rebootNeeded)
                  FilledButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await widget.sendCommand('reboot');
                      nav.pop();
                    },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Reboot now'),
                  ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final atStart = _step == 0;
    final atEnd = _step == _wizardSteps.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: MeshResponsive.gap(context),
        runSpacing: MeshResponsive.gap(context),
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: atStart ? null : () => setState(() => _step--),
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('Back'),
          ),
          if (!atEnd)
            FilledButton.icon(
              onPressed: () => setState(() => _step++),
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next'),
            )
          else
            FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Apply'),
            ),
        ],
      ),
    );
  }
}

class _WizardField extends StatelessWidget {
  const _WizardField({
    required this.entry,
    required this.onChanged,
    this.result,
  });

  final _Entry entry;
  final VoidCallback onChanged;
  final bool? result;

  @override
  Widget build(BuildContext context) {
    final bg = result == null
        ? entry.changed
            ? Colors.orange.withValues(alpha: 0.07)
            : null
        : (result! ? Colors.green : Colors.red).withValues(alpha: 0.08);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < MeshResponsive.mobileMax;
          final label = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.param.label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text(entry.param.key,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          );
          final input = _WizardInput(entry: entry, onChanged: onChanged);
          final resultIcon = SizedBox(
            width: 28,
            child: result == null
                ? null
                : Icon(
                    result!
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: result! ? Colors.green : Colors.red,
                    size: 18,
                  ),
          );

          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: label), resultIcon]),
                const SizedBox(height: 6),
                input,
              ],
            );
          }

          return Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 210),
                child: label,
              ),
              const SizedBox(width: 12),
              Expanded(child: input),
              resultIcon,
            ],
          );
        },
      ),
    );
  }
}

class _RegionWizardFields extends StatelessWidget {
  const _RegionWizardFields({
    required this.homeController,
    required this.defaultController,
    required this.allowedController,
    required this.deniedController,
    required this.putController,
    required this.lookupController,
    required this.onChanged,
    required this.onFind,
    required this.onUseLookup,
    required this.onAddGermanPreset,
    required this.busy,
    this.dbInfo,
    this.dbProvinces,
    this.tree,
    this.lookupResult,
    this.lookupCode,
  });

  final TextEditingController homeController;
  final TextEditingController defaultController;
  final TextEditingController allowedController;
  final TextEditingController deniedController;
  final TextEditingController putController;
  final TextEditingController lookupController;
  final VoidCallback onChanged;
  final VoidCallback onFind;
  final VoidCallback onUseLookup;
  final VoidCallback onAddGermanPreset;
  final bool busy;
  final String? dbInfo;
  final String? dbProvinces;
  final String? tree;
  final String? lookupResult;
  final String? lookupCode;

  @override
  Widget build(BuildContext context) {
    final gap = MeshResponsive.gap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if ((dbInfo ?? '').isNotEmpty || (dbProvinces ?? '').isNotEmpty)
          _RegionInfoBlock(
            title: 'Dutch region database',
            text: [
              if ((dbInfo ?? '').isNotEmpty) dbInfo,
              if ((dbProvinces ?? '').isNotEmpty) dbProvinces,
            ].whereType<String>().join('\n'),
          ),
        if ((tree ?? '').isNotEmpty) ...[
          SizedBox(height: gap),
          _RegionInfoBlock(title: 'Current region tree', text: tree!),
        ],
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: lookupController,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Dutch location lookup',
                  hintText: 'gron, bovenkarspel, alkmaar',
                ),
                onSubmitted: (_) => onFind(),
              ),
            ),
            SizedBox(width: gap),
            FilledButton.icon(
              onPressed: busy ? null : onFind,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, size: 18),
              label: const Text('Find'),
            ),
          ],
        ),
        if ((lookupResult ?? '').isNotEmpty) ...[
          SizedBox(height: gap),
          _RegionInfoBlock(title: 'Lookup result', text: lookupResult!),
          if (lookupCode != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onUseLookup,
                icon: const Icon(Icons.add_location_alt, size: 18),
                label: Text('Use $lookupCode'),
              ),
            ),
        ],
        SizedBox(height: gap),
        _RegionTextField(
          controller: homeController,
          label: 'Home region',
          hint: 'nl-nh-bov or de-nw',
          onChanged: onChanged,
        ),
        SizedBox(height: gap),
        _RegionTextField(
          controller: defaultController,
          label: 'Default scope',
          hint: 'nl, de or <null>',
          onChanged: onChanged,
        ),
        SizedBox(height: gap),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onAddGermanPreset,
            icon: const Icon(Icons.add_location_alt, size: 18),
            label: const Text('Add German states'),
          ),
        ),
        SizedBox(height: gap),
        _RegionTextField(
          controller: putController,
          label: 'Create / move regions',
          hint: 'one per line: nl-nh-bov nl-nh, de-nw de',
          minLines: 2,
          maxLines: 5,
          onChanged: onChanged,
        ),
        SizedBox(height: gap),
        _RegionTextField(
          controller: allowedController,
          label: 'Allowed flood regions',
          hint: 'one per line: nl, de, nl-nh, de-nw',
          minLines: 3,
          maxLines: 6,
          onChanged: onChanged,
        ),
        SizedBox(height: gap),
        _RegionTextField(
          controller: deniedController,
          label: 'Denied flood regions',
          hint: 'one per line: eu, *',
          minLines: 2,
          maxLines: 5,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RegionInfoBlock extends StatelessWidget {
  const _RegionInfoBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: cs.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionTextField extends StatelessWidget {
  const _RegionTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onChanged;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
      ),
      onChanged: (_) => onChanged(),
    );
  }
}

class _WizardInput extends StatelessWidget {
  const _WizardInput({
    required this.entry,
    required this.onChanged,
  });

  final _Entry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (entry.param.isDropdown) {
      return DropdownButton<String>(
        value: entry.dropdownValue,
        isExpanded: true,
        isDense: true,
        items: [
          for (final opt in entry.param.options!)
            DropdownMenuItem(value: opt, child: Text(opt)),
        ],
        onChanged: (value) {
          entry.dropdownValue = value;
          onChanged();
        },
      );
    }

    return TextFormField(
      controller: entry.controller,
      obscureText: entry.param.isSecret,
      decoration: InputDecoration(
        isDense: true,
        hintText:
            entry.param.isSecret ? '(leave blank to keep unchanged)' : null,
        hintStyle: const TextStyle(fontSize: 11),
        suffix: entry.param.unit.isNotEmpty
            ? Text(entry.param.unit,
                style: const TextStyle(fontSize: 11, color: Colors.grey))
            : null,
      ),
      onChanged: (_) => onChanged(),
    );
  }
}

// ─── TCP Bridge wizard ────────────────────────────────────────

class TcpBridgeWizardDialog extends StatefulWidget {
  const TcpBridgeWizardDialog({
    super.key,
    required this.deviceName,
    required this.queryParam,
    required this.setParam,
    required this.sendCommand,
  });

  final String deviceName;
  final Future<String?> Function(String key) queryParam;
  final Future<String?> Function(String key, String value) setParam;
  final Future<void> Function(String command) sendCommand;

  @override
  State<TcpBridgeWizardDialog> createState() => _TcpBridgeWizardDialogState();
}

enum _BridgePhase { checking, unsupported, loading, editing, applying, done }

const _tcpBridgeSteps = <_WizardStep>[
  _WizardStep('WiFi', ['wifi.ssid', 'wifi.password']),
  _WizardStep('Bridge server', ['bridge.server', 'bridge.port', 'bridge.password']),
  _WizardStep('Options', ['bridge.enabled', 'bridge.rf', 'bridge.source']),
];

class _TcpBridgeWizardDialogState extends State<TcpBridgeWizardDialog> {
  late final Map<String, _Entry> _entries;
  _BridgePhase _phase = _BridgePhase.checking;
  String? _bridgeType;
  String? _wifiStatus;
  int _step = 0;
  int _changedCount = 0;
  bool _rebootNeeded = false;
  final _results = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _entries = {
      for (final step in _tcpBridgeSteps)
        for (final key in step.keys)
          key: _Entry(_paramsByKey[key]!),
    };
    _checkAndLoad();
  }

  @override
  void dispose() {
    for (final e in _entries.values) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAndLoad() async {
    final bridgeType = await widget.queryParam('bridge.type');
    if (!mounted) return;
    if (bridgeType?.toLowerCase().contains('tcp') != true) {
      setState(() {
        _bridgeType = bridgeType ?? 'none';
        _phase = _BridgePhase.unsupported;
      });
      return;
    }
    setState(() {
      _bridgeType = bridgeType;
      _phase = _BridgePhase.loading;
    });

    for (final entry in _entries.values) {
      if (!mounted) return;
      if (entry.param.isSecret) continue;
      String? value = await widget.queryParam(entry.param.key);
      if (!mounted) return;
      // normalize bridge.source: firmware returns "logTx"/"logRx"/"both",
      // but set expects "tx"/"rx"
      if (entry.param.key == 'bridge.source' && value != null) {
        value = value.toLowerCase().contains('rx') ? 'rx' : 'tx';
      }
      setState(() => entry.init(value));
    }

    final wifiStatus = await widget.queryParam('wifi.status');
    if (!mounted) return;

    setState(() {
      _wifiStatus = wifiStatus;
      _phase = _BridgePhase.editing;
    });
  }

  Future<void> _apply() async {
    final toApply = _entries.values
        .where((e) => e.changed && e.current.isNotEmpty)
        .toList();
    if (toApply.isEmpty) {
      setState(() {
        _changedCount = 0;
        _phase = _BridgePhase.done;
      });
      return;
    }
    setState(() {
      _phase = _BridgePhase.applying;
      _changedCount = toApply.length;
    });
    for (final entry in toApply) {
      if (!mounted) return;
      final response = await widget.setParam(entry.param.key, entry.current);
      if (!mounted) return;
      final ok = response == null || !response.toLowerCase().contains('error');
      setState(() {
        _results[entry.param.key] = ok;
        if (ok && entry.param.requiresReboot) _rebootNeeded = true;
      });
    }
    if (mounted) setState(() => _phase = _BridgePhase.done);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Dialog(
        insetPadding: EdgeInsets.all(MeshResponsive.pagePadding(context)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width < MeshResponsive.mobileMax
                ? MediaQuery.sizeOf(context).width
                : 680,
            maxHeight: (MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    MeshResponsive.pagePadding(context) * 2)
                .clamp(360.0, 760.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(children: [
                  const Icon(Icons.wifi),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'TCP bridge wizard: ${widget.deviceName}',
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
              Expanded(child: _buildBody(cs)),
              _buildFooter(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    switch (_phase) {
      case _BridgePhase.checking:
        return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking bridge type…'),
          ]),
        );
      case _BridgePhase.unsupported:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text('TCP bridge not supported',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Bridge type on this device: ${_bridgeType ?? 'none'}\n\n'
                'A firmware build with WITH_TCP_BRIDGE is required.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ]),
          ),
        );
      case _BridgePhase.loading:
        return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading current bridge settings…'),
          ]),
        );
      case _BridgePhase.applying:
        return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Applying bridge settings…'),
          ]),
        );
      case _BridgePhase.done:
        final failed = _results.entries.where((e) => !e.value).length;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                failed == 0 ? Icons.check_circle_outline : Icons.error_outline,
                size: 48,
                color: failed == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                failed == 0
                    ? 'TCP bridge configured successfully'
                    : '$failed setting${failed == 1 ? '' : 's'} failed to apply',
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        );
      case _BridgePhase.editing:
        return Stepper(
          currentStep: _step,
          type: StepperType.vertical,
          controlsBuilder: (_, __) => const SizedBox.shrink(),
          onStepTapped: (i) => setState(() => _step = i),
          steps: [
            for (var i = 0; i < _tcpBridgeSteps.length; i++)
              Step(
                title: Text(_tcpBridgeSteps[i].title),
                isActive: i == _step,
                state: i < _step ? StepState.complete : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (i == 0) ...[
                      _RegionInfoBlock(
                        title: 'Bridge type',
                        text: _bridgeType ?? 'tcp',
                      ),
                      const SizedBox(height: 8),
                      if ((_wifiStatus ?? '').isNotEmpty) ...[
                        _RegionInfoBlock(
                          title: 'Current WiFi / bridge status',
                          text: _wifiStatus!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Text(
                        'WiFi SSID and password require a reboot to take effect.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (i == 1)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Default port is 4200. Leave bridge auth password blank if the server does not require one.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    if (i == 2)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'bridge.rf: allow packets received from the bridge server to be re-transmitted on RF.\n'
                          'bridge.source: which packets are forwarded — tx = packets this node sends, rx = packets this node receives.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    for (final key in _tcpBridgeSteps[i].keys)
                      _WizardField(
                        entry: _entries[key]!,
                        result: _results[key],
                        onChanged: () => setState(() {}),
                      ),
                  ],
                ),
              ),
          ],
        );
    }
  }

  Widget _buildFooter(ColorScheme cs) {
    switch (_phase) {
      case _BridgePhase.checking:
      case _BridgePhase.loading:
      case _BridgePhase.applying:
        return const SizedBox.shrink();

      case _BridgePhase.unsupported:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        );

      case _BridgePhase.done:
        return Column(
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
                      'WiFi credentials changed — reboot so the bridge can connect.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: MeshResponsive.gap(context),
                runSpacing: MeshResponsive.gap(context),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$_changedCount change${_changedCount == 1 ? '' : 's'} applied',
                    style: TextStyle(color: cs.secondary),
                  ),
                  if (_rebootNeeded)
                    FilledButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await widget.sendCommand('reboot');
                        nav.pop();
                      },
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reboot now'),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        );

      case _BridgePhase.editing:
        final atStart = _step == 0;
        final atEnd = _step == _tcpBridgeSteps.length - 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: MeshResponsive.gap(context),
            runSpacing: MeshResponsive.gap(context),
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              OutlinedButton.icon(
                onPressed: atStart ? null : () => setState(() => _step--),
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Back'),
              ),
              if (!atEnd)
                FilledButton.icon(
                  onPressed: () => setState(() => _step++),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Next'),
                )
              else
                FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Apply'),
                ),
            ],
          ),
        );
    }
  }
}

// ─── Serial config dialog ─────────────────────────────────────

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
    for (final e in _entries) {
      e.dispose();
    }
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
                'bw': parts[1].trim(),
                'sf': parts[2].trim(),
                'cr': parts[3].trim(),
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
    final toApply =
        _entries.where((e) => e.changed && e.current.isNotEmpty).toList();
    if (toApply.isEmpty) {
      setState(() {
        _changedCount = 0;
        _phase = _Phase.done;
      });
      return;
    }
    setState(() {
      _phase = _Phase.applying;
      _changedCount = toApply.length;
    });
    for (final entry in toApply) {
      if (!mounted) return;
      final response = await widget.setParam(entry.param.key, entry.current);
      if (!mounted) return;
      final ok = response == null || !response.toLowerCase().contains('error');
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
    return SafeArea(
      child: Dialog(
        insetPadding: EdgeInsets.all(MeshResponsive.pagePadding(context)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.sizeOf(context);
            final maxWidth =
                size.width < MeshResponsive.mobileMax ? size.width : 620.0;
            final maxHeight = size.height -
                MediaQuery.paddingOf(context).vertical -
                MeshResponsive.pagePadding(context) * 2;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight.clamp(320.0, 720.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Responsive header prevents long device names from forcing
                  // the close button off small Android screens.
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MeshResponsive.isMobile(context) ? 14 : 20,
                      vertical: 14,
                    ),
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
                          'Configure ${widget.deviceName}',
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
                  Expanded(child: _buildBody()),
                  _buildFooter(cs),
                ],
              ),
            );
          },
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
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Applying changes…'),
          ]),
        ),
      _Phase.editing => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: MeshResponsive.gap(context),
            runSpacing: MeshResponsive.gap(context),
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Apply changes'),
              ),
            ],
          ),
        ),
      _Phase.done => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_rebootNeeded)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.4)),
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
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: MeshResponsive.gap(context),
                runSpacing: MeshResponsive.gap(context),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$_changedCount change${_changedCount == 1 ? '' : 's'} applied',
                    style: TextStyle(color: cs.secondary),
                  ),
                  if (_rebootNeeded)
                    FilledButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await widget.sendCommand('reboot');
                        nav.pop();
                      },
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reboot now'),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
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
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.6),
        ),
      ));
      for (final param in section.params) {
        rows.add(_buildRow(_entryMap[param.key]!));
      }
    }
    return ListView(padding: const EdgeInsets.only(bottom: 8), children: rows);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < MeshResponsive.mobileMax;
            final label = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.param.label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(key,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            );
            final resultIcon = SizedBox(
              width: 28,
              child: hasResult
                  ? Icon(
                      ok ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: ok ? Colors.green : Colors.red,
                      size: 18,
                    )
                  : null,
            );

            if (mobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [Expanded(child: label), resultIcon]),
                  const SizedBox(height: 6),
                  _buildInput(entry, editable),
                ],
              );
            }

            return Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 210),
                  child: label,
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(entry, editable)),
                resultIcon,
              ],
            );
          },
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
        onChanged:
            editable ? (v) => setState(() => entry.dropdownValue = v) : null,
      );
    }
    return TextFormField(
      controller: entry.controller,
      enabled: editable,
      obscureText: entry.param.isSecret,
      decoration: InputDecoration(
        isDense: true,
        hintText:
            entry.param.isSecret ? '(leave blank to keep unchanged)' : null,
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
