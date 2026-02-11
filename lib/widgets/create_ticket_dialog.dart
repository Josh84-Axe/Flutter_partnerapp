import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/support_ticket_service.dart';
import '../providers/split/auth_provider.dart';

class CreateTicketDialog extends StatefulWidget {
  const CreateTicketDialog({super.key});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Note: API spec asks for 'priority', but UI had 'category' too. 
  // We'll keep both for UI but map as needed or include in description if API doesn't support category.
  String _selectedCategory = 'technical';
  String _selectedPriority = 'MEDIUM'; // API expects uppercase: LOW, MEDIUM, HIGH, URGENT

  final List<String> _categories = ['general', 'sales', 'partnership', 'technical'];
  // Updated to match API requirements
  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Get current user details
      // Assuming AuthProvider has the latest user info.
      // If AuthProvider is not available or doesn't have user, we might fail or use defaults.
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not found. Please log in.')),
        );
        return;
      }

      final service = SupportTicketService();
      // Combining category into description if API doesn't support it directly
      final fullDescription = '[Category: ${_selectedCategory.toUpperCase()}]\n\n${_descriptionController.text.trim()}';

      try {
        final success = await service.createTicket(
          subject: _subjectController.text.trim(),
          description: fullDescription,
          contactName: currentUser.name ?? 'Valued Partner',
          contactEmail: currentUser.email,
          priority: _selectedPriority,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            Navigator.of(context).pop();
            _showSuccessDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ticket_creation_failed'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('success'.tr()),
          ],
        ),
        content: const Text('Your ticket has been created successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fallback translations check
    // Ensure you have these keys in your localization files or provide defaults.
    
    return AlertDialog(
      title: Text('create_ticket'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'subject'.tr(),
                  hintText: 'brief_summary_issue'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'category'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'priority'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: _priorities.map((prio) {
                  return DropdownMenuItem(
                    value: prio,
                    child: Text(prio),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr(),
                  hintText: 'detailed_explanation'.tr(),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'field_required'.tr();
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitTicket,
          child: _isLoading 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                )
              : Text('submit'.tr()),
        ),
      ],
    );
  }
}
