import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';
import '../models/family_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

// (ScreenTimeRule class moved to family_models.dart)

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class FamilyRulesScreen extends StatefulWidget {
  const FamilyRulesScreen({super.key});

  @override
  State<FamilyRulesScreen> createState() => _FamilyRulesScreenState();
}

class _FamilyRulesScreenState extends State<FamilyRulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;



  Future<void> _applyPreset(_Preset preset) async {
    final provider = context.read<FamilyProvider>();
    final devices = provider.devices;
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices found. Add a device first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    FamilyDevice selectedDevice = devices.first;
    if (devices.length > 1) {
      final chosen = await showDialog<FamilyDevice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Apply "${preset.title}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select target device:'),
              const SizedBox(height: 12),
              ...devices.map((d) => ListTile(
                    leading: const Icon(Icons.smartphone),
                    title: Text(d.deviceName),
                    onTap: () => Navigator.pop(ctx, d),
                  )),
            ],
          ),
        ),
      );
      if (chosen == null) return;
      selectedDevice = chosen;
    }

    final rule = preset.toRule(selectedDevice);
    final success = await provider.addRule(rule);

    if (mounted) {
      if (success) {
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${preset.title}" applied to ${selectedDevice.deviceName}. Customise it in My Rules.'),
            backgroundColor: preset.color,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to apply rule preset'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddRuleSheet() async {
    final provider = context.read<FamilyProvider>();
    final devices = provider.devices;
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No devices found. Add a device first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newRule = await showModalBottomSheet<ScreenTimeRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddRuleSheet(devices: devices),
    );

    if (newRule != null) {
      provider.addRule(newRule);
    }
  }

  void _deleteRule(ScreenTimeRule rule) {
    context.read<FamilyProvider>().deleteRule(rule);
  }

  void _toggleRule(ScreenTimeRule rule, bool val) {
    rule.isEnabled = val;
    context.read<FamilyProvider>().updateRule(rule);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: const Text(
              'Screen Time Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Rules'),
                Tab(text: 'Quick Presets'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _RulesTab(
              rules: provider.rules,
              onToggle: _toggleRule,
              onDelete: _deleteRule,
              onAdd: _showAddRuleSheet,
            ),
            _PresetsTab(onApply: _applyPreset),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRuleSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Rule'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rules Tab
// ─────────────────────────────────────────────────────────────────────────────

class _RulesTab extends StatelessWidget {
  final List<ScreenTimeRule> rules;
  final void Function(ScreenTimeRule rule, bool val) onToggle;
  final void Function(ScreenTimeRule rule) onDelete;
  final VoidCallback onAdd;

  const _RulesTab({
    required this.rules,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return _EmptyState(onAdd: onAdd);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: rules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final rule = rules[i];
        return _RuleCard(
          rule: rule,
          onToggle: (val) => onToggle(rule, val),
          onDelete: () => onDelete(rule),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule Card
// ─────────────────────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final ScreenTimeRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onDelete,
  });

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  String _formatLimit(int minutes) {
    if (minutes == 0) return 'Unlimited';
    if (minutes < 60) return '${minutes}min/day';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h/day' : '${h}h ${m}min/day';
  }

  String _formatWindow(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) return 'Any time';
    String f(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${f(start)} – ${f(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = rule.isEnabled;

    return Dismissible(
      key: Key(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 250),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.timer_outlined,
                          color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rule.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(rule.deviceName,
                              style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(value: isActive, onChanged: onToggle),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.hourglass_bottom,
                      label: _formatLimit(rule.dailyLimitMinutes),
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.access_time,
                      label: _formatWindow(rule.accessStart, rule.accessEnd),
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Day chips
                Wrap(
                  spacing: 4,
                  children: List.generate(7, (i) {
                    final active = rule.allowedDays.contains(i);
                    return _DayChip(
                      label: _dayLabels[i],
                      active: active,
                      color: colorScheme.primary,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;

  const _DayChip(
      {required this.label, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : color.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presets Tab
// ─────────────────────────────────────────────────────────────────────────────

class _PresetsTab extends StatelessWidget {
  final void Function(_Preset preset) onApply;
  const _PresetsTab({required this.onApply});

  static const _presets = [
    _Preset(
      icon: Icons.bedtime_outlined,
      title: 'Bedtime Mode',
      subtitle: 'Block internet 9 PM – 7 AM every day',
      color: Color(0xFF5C6BC0),
      accessStart: TimeOfDay(hour: 21, minute: 0),
      accessEnd: TimeOfDay(hour: 7, minute: 0),
    ),
    _Preset(
      icon: Icons.school_outlined,
      title: 'School Hours',
      subtitle: 'Block internet Mon–Fri, 8 AM – 3 PM',
      color: Color(0xFF26A69A),
      allowedDays: [0, 1, 2, 3, 4],
      accessStart: TimeOfDay(hour: 8, minute: 0),
      accessEnd: TimeOfDay(hour: 15, minute: 0),
    ),
    _Preset(
      icon: Icons.weekend_outlined,
      title: 'Weekend Limits',
      subtitle: 'Max 3 hours/day on Sat & Sun',
      color: Color(0xFFEF6C00),
      dailyLimitMinutes: 180,
      allowedDays: [5, 6],
    ),
    _Preset(
      icon: Icons.dinner_dining_outlined,
      title: 'Dinner Time',
      subtitle: 'Block internet 6 PM – 7 PM every day',
      color: Color(0xFFC62828),
      accessStart: TimeOfDay(hour: 18, minute: 0),
      accessEnd: TimeOfDay(hour: 19, minute: 0),
    ),
    _Preset(
      icon: Icons.child_care_outlined,
      title: 'Young Child',
      subtitle: 'Max 1 hour/day, allowed 3 PM – 6 PM',
      color: Color(0xFF8E24AA),
      dailyLimitMinutes: 60,
      accessStart: TimeOfDay(hour: 15, minute: 0),
      accessEnd: TimeOfDay(hour: 18, minute: 0),
    ),
    _Preset(
      icon: Icons.sports_esports_outlined,
      title: 'Homework First',
      subtitle: 'Block Mon–Fri until 4 PM',
      color: Color(0xFF388E3C),
      allowedDays: [0, 1, 2, 3, 4],
      accessStart: TimeOfDay(hour: 16, minute: 0),
      accessEnd: TimeOfDay(hour: 21, minute: 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: _presets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = _presets[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(p.icon, color: p.color, size: 22),
            ),
            title: Text(p.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(p.subtitle,
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13)),
            trailing: OutlinedButton(
              onPressed: () => onApply(p),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.color,
                side: BorderSide(color: p.color),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Apply'),
            ),
          ),
        );
      },
    );
  }
}

class _Preset {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int dailyLimitMinutes;
  final List<int> allowedDays;
  final TimeOfDay? accessStart;
  final TimeOfDay? accessEnd;

  const _Preset({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.dailyLimitMinutes = 0,
    this.allowedDays = const [0, 1, 2, 3, 4, 5, 6],
    this.accessStart,
    this.accessEnd,
  });

  ScreenTimeRule toRule(FamilyDevice device) => ScreenTimeRule(
    id: '${DateTime.now().millisecondsSinceEpoch}_preset',
    label: title,
    deviceName: device.deviceName,
    deviceId: device.id,
    dailyLimitMinutes: dailyLimitMinutes,
    allowedDays: allowedDays,
    accessStart: accessStart,
    accessEnd: accessEnd,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer_outlined,
                  size: 48, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Rules Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Set daily time limits and allowed access windows\nfor each device in your home.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 15),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create a Rule'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Rule Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddRuleSheet extends StatefulWidget {
  final List<FamilyDevice> devices;

  const _AddRuleSheet({required this.devices});

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  FamilyDevice? _selectedDevice;
  double _dailyLimitMinutes = 120; // 2 hours default
  bool _hasTimeWindow = false;
  TimeOfDay _accessStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _accessEnd = const TimeOfDay(hour: 21, minute: 0);
  final Set<int> _selectedDays = {0, 1, 2, 3, 4, 5, 6};
  bool _unlimitedTime = false;

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  String _formatMinutes(double mins) {
    if (_unlimitedTime) return 'Unlimited';
    final m = mins.toInt();
    if (m < 60) return '${m}min';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}min';
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedDevice == null) return;

    final rule = ScreenTimeRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      deviceName: _selectedDevice!.deviceName,
      deviceId: _selectedDevice!.id,
      dailyLimitMinutes: _unlimitedTime ? 0 : _dailyLimitMinutes.toInt(),
      allowedDays: _selectedDays.toList()..sort(),
      accessStart: _hasTimeWindow ? _accessStart : null,
      accessEnd: _hasTimeWindow ? _accessEnd : null,
    );

    Navigator.pop(context, rule);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
                children: [
                  Text('New Screen Time Rule',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Set limits on when and how long a device can be used.',
                      style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rule label
                        TextFormField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Rule Name',
                            hintText: 'e.g. Bedtime, School Day',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Device selector
                        DropdownButtonFormField<FamilyDevice>(
                          decoration: InputDecoration(
                            labelText: 'Device',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: widget.devices
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text(d.deviceName)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDevice = v),
                          validator: (v) => v == null ? 'Select a device' : null,
                        ),
                        const SizedBox(height: 24),

                        // Daily Limit
                        _SectionHeader(
                            icon: Icons.hourglass_bottom,
                            label: 'Daily Time Limit'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _unlimitedTime ? 480 : _dailyLimitMinutes,
                                min: 15,
                                max: 480,
                                divisions: 31,
                                onChanged: _unlimitedTime
                                    ? null
                                    : (v) => setState(
                                        () => _dailyLimitMinutes = v),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _formatMinutes(_dailyLimitMinutes),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Unlimited'),
                            Switch(
                              value: _unlimitedTime,
                              onChanged: (v) =>
                                  setState(() => _unlimitedTime = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Allowed Days
                        _SectionHeader(
                            icon: Icons.calendar_today_outlined,
                            label: 'Allowed Days'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (i) {
                            final active = _selectedDays.contains(i);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (active) {
                                  _selectedDays.remove(i);
                                } else {
                                  _selectedDays.add(i);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                                ),
                                child: Text(
                                  _dayLabels[i],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: active
                                        ? Colors.white
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Access Window
                        _SectionHeader(
                            icon: Icons.access_time_outlined,
                            label: 'Restrict to Time Window'),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Only allow access between set hours',
                                style: TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 13),
                              ),
                            ),
                            Switch(
                              value: _hasTimeWindow,
                              onChanged: (v) =>
                                  setState(() => _hasTimeWindow = v),
                            ),
                          ],
                        ),
                        if (_hasTimeWindow) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _TimeTile(
                                  label: 'From',
                                  time: _accessStart,
                                  onTap: () async {
                                    final t = await showTimePicker(
                                        context: context,
                                        initialTime: _accessStart);
                                    if (t != null) {
                                      setState(() => _accessStart = t);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TimeTile(
                                  label: 'Until',
                                  time: _accessEnd,
                                  onTap: () async {
                                    final t = await showTimePicker(
                                        context: context,
                                        initialTime: _accessEnd);
                                    if (t != null) {
                                      setState(() => _accessEnd = t);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Save Rule',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colorScheme.onSurface)),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeTile(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
