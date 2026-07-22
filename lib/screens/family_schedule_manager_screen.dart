import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';
import '../services/family_api_service.dart';
import '../models/family_models.dart';

class FamilyScheduleManagerScreen extends StatefulWidget {
  const FamilyScheduleManagerScreen({super.key});

  @override
  State<FamilyScheduleManagerScreen> createState() => _FamilyScheduleManagerScreenState();
}

class _FamilyScheduleManagerScreenState extends State<FamilyScheduleManagerScreen> {
  // Mock data for initial UI before integrating full schedule fetching from API
  final List<PolicySchedule> _schedules = [];

  void _showNewScheduleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NewScheduleForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Schedules'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewScheduleModal,
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
      body: _schedules.isEmpty
          ? const Center(
              child: Text(
                'No schedules found.\nCreate one to automate internet access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                return Card(
                  child: ListTile(
                    title: Text(schedule.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Day: ${schedule.dayOfWeek} | ${schedule.startTime} - ${schedule.endTime}'),
                    trailing: Switch(
                      value: schedule.isActive,
                      onChanged: (val) {},
                    ),
                  ),
                );
              },
            ),
    );
  }
}

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
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDevice == null) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await FamilyApiService.createSchedule(
        _selectedDevice!.id,
        _nameController.text.trim(),
        _selectedDay,
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        1, // Defaulting policy ID to 1 for demo purposes
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Create New Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Schedule Name (e.g. Bedtime)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FamilyDevice>(
              initialValue: _selectedDevice,
              decoration: const InputDecoration(labelText: 'Select Device'),
              items: devices.map((d) => DropdownMenuItem(value: d, child: Text(d.deviceName))).toList(),
              onChanged: (val) => setState(() => _selectedDevice = val),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedDay,
              decoration: const InputDecoration(labelText: 'Day of Week'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Monday')),
                DropdownMenuItem(value: 1, child: Text('Tuesday')),
                DropdownMenuItem(value: 2, child: Text('Wednesday')),
                DropdownMenuItem(value: 3, child: Text('Thursday')),
                DropdownMenuItem(value: 4, child: Text('Friday')),
                DropdownMenuItem(value: 5, child: Text('Saturday')),
                DropdownMenuItem(value: 6, child: Text('Sunday')),
                DropdownMenuItem(value: 7, child: Text('Everyday')),
              ],
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
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
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Schedule'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
