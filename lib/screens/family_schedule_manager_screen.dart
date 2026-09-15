import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/family_provider.dart';
import '../services/family_api_service.dart';
import '../models/family_models.dart';

class FamilyScheduleManagerScreen extends StatefulWidget {
  const FamilyScheduleManagerScreen({super.key});

  @override
  State<FamilyScheduleManagerScreen> createState() => _FamilyScheduleManagerScreenState();
}

class _FamilyScheduleManagerScreenState extends State<FamilyScheduleManagerScreen> {
  List<PolicySchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    final provider = context.read<FamilyProvider>();
    List<FamilyDevice> devices = provider.devices;
    if (devices.isEmpty) {
      await provider.loadData();
      devices = provider.devices;
    }
    final schedules = await FamilyApiService.fetchAllSchedules(devices);
    if (mounted) {
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSchedule(PolicySchedule schedule, bool value) async {
    final idx = _schedules.indexOf(schedule);
    setState(() {
      _schedules[idx] = PolicySchedule(
        id: schedule.id,
        deviceId: schedule.deviceId,
        name: schedule.name,
        dayOfWeek: schedule.dayOfWeek,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        policyId: schedule.policyId,
        isActive: value,
      );
    });
    final ok = await FamilyApiService.toggleScheduleActive(schedule.deviceId, schedule.id, value);
    if (!ok && mounted) {
      // Revert on failure
      setState(() {
        _schedules[idx] = schedule;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_update_schedule'.tr()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteSchedule(PolicySchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_schedule'.tr()),
        content: Text('remove_schedule_confirm'.tr(namedArgs: {'name': schedule.name})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await FamilyApiService.deleteSchedule(schedule.deviceId, schedule.id);
    if (ok && mounted) {
      setState(() => _schedules.remove(schedule));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('schedule_deleted'.tr()), backgroundColor: Colors.orange),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_delete_schedule'.tr()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showNewScheduleModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NewScheduleForm(),
    );
    _loadSchedules();
  }

  String _dayName(int day) {
    final days = [
      'day_mon'.tr(),
      'day_tue'.tr(),
      'day_wed'.tr(),
      'day_thu'.tr(),
      'day_fri'.tr(),
      'day_sat'.tr(),
      'day_sun'.tr(),
      'day_everyday'.tr(),
    ];
    return day < days.length ? days[day] : 'Day $day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_schedules'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
            tooltip: 'refresh'.tr(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewScheduleModal,
        icon: const Icon(Icons.add),
        label: Text('new_schedule'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'no_schedules_found'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Dismissible(
                      key: Key('schedule-${schedule.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteSchedule(schedule);
                        return false; // We manage state ourselves
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: schedule.isActive
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                                : Colors.grey.shade200,
                            child: Icon(
                              Icons.schedule,
                              color: schedule.isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            schedule.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${_dayName(schedule.dayOfWeek)}  •  ${schedule.startTime} – ${schedule.endTime}',
                          ),
                          trailing: Switch(
                            value: schedule.isActive,
                            onChanged: (val) => _toggleSchedule(schedule, val),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ─── New Schedule Form ────────────────────────────────────────────────────────

class _NewScheduleForm extends StatefulWidget {
  const _NewScheduleForm();

  @override
  State<_NewScheduleForm> createState() => _NewScheduleFormState();
}

class _NewScheduleFormState extends State<_NewScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _selectedDay = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 6, minute: 0);
  FamilyDevice? _selectedDevice;
  ContentPolicy? _selectedPolicy;
  List<ContentPolicy> _policies = [];
  bool _isSubmitting = false;
  bool _loadingPolicies = true;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    final policies = await FamilyApiService.fetchPolicies(forSchedule: true);
    if (mounted) {
      setState(() {
        _policies = policies;
        if (policies.isNotEmpty) _selectedPolicy = policies.first;
        _loadingPolicies = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDevice == null || _selectedPolicy == null) return;
    setState(() => _isSubmitting = true);

    try {
      await FamilyApiService.createSchedule(
        _selectedDevice!.id,
        _nameController.text.trim(),
        _selectedDay,
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        _selectedPolicy!.id,
      );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('schedule_created'.tr()), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final devices = provider.devices;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('create_new_schedule'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'schedule_name_hint'.tr()),
                validator: (v) => v!.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FamilyDevice>(
                initialValue: _selectedDevice,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'select_device'.tr(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: devices
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.deviceName, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDevice = val),
                validator: (v) => v == null ? 'please_select_device'.tr() : null,
              ),
              const SizedBox(height: 16),
              _loadingPolicies
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<ContentPolicy>(
                      initialValue: _selectedPolicy,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'apply_action_policy'.tr(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _policies
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.displayName, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedPolicy = val),
                      validator: (v) => v == null ? 'please_select_policy'.tr() : null,
                    ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: InputDecoration(labelText: 'day_of_week'.tr()),
                items: [
                  DropdownMenuItem(value: 0, child: Text('day_monday'.tr())),
                  DropdownMenuItem(value: 1, child: Text('day_tuesday'.tr())),
                  DropdownMenuItem(value: 2, child: Text('day_wednesday'.tr())),
                  DropdownMenuItem(value: 3, child: Text('day_thursday'.tr())),
                  DropdownMenuItem(value: 4, child: Text('day_friday'.tr())),
                  DropdownMenuItem(value: 5, child: Text('day_saturday'.tr())),
                  DropdownMenuItem(value: 6, child: Text('day_sunday'.tr())),
                  DropdownMenuItem(value: 7, child: Text('day_everyday'.tr())),
                ],
                onChanged: (val) => setState(() => _selectedDay = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('start_time'.tr()),
                      subtitle: Text(_startTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _startTime);
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('end_time'.tr()),
                      subtitle: Text(_endTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _endTime);
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('save_schedule'.tr()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
