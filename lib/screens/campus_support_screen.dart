import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/campus_provider.dart';

class CampusSupportScreen extends StatefulWidget {
  const CampusSupportScreen({super.key});

  @override
  State<CampusSupportScreen> createState() => _CampusSupportScreenState();
}

class _CampusSupportScreenState extends State<CampusSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _issueType = 'Slow Internet';
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      final success = await context.read<CampusProvider>().submitSupportTicket(
        _issueType,
        _descController.text,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support ticket submitted successfully!')),
        );
        _descController.clear();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<CampusProvider>().error ?? 'Failed to submit ticket')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IT Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How can we help?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const Text('Submit a ticket to the campus ISP partner.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Submit a Ticket', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _issueType,
                    decoration: const InputDecoration(
                      labelText: 'Issue Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Slow Internet', child: Text('Slow Internet')),
                      DropdownMenuItem(value: 'Cannot Connect', child: Text('Cannot Connect')),
                      DropdownMenuItem(value: 'Payment Issue', child: Text('Payment Issue')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _issueType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submitTicket,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Ticket'),
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
