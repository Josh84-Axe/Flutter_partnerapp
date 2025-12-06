ö8import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isLoading = false;
  List<dynamic> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      final methods = await appState.paymentMethodRepository.fetchPaymentMethods();
      
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_loading_payment_methods'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCreatePaymentMethodDialog() async {
    // Navigate to the dedicated Add Payout Method screen which handles OTP flow
    final result = await Navigator.pushNamed(context, '/add-payout-method');
    
    if (result == true && mounted) {
      // Reload the list if a payment method was added
      _loadPaymentMethods();
    }
  }

  Future<void> _deletePaymentMethod(String slug) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_payment_method'.tr()),
        content: Text('delete_payment_method_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final appState = context.read<AppState>();
      final success = await appState.paymentMethodRepository.deletePaymentMethod(slug);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('payment_method_deleted_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          _loadPaymentMethods();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_deleting_payment_method'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('payment_methods'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentMethods,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_payment_methods'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'no_payment_methods_desc'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPaymentMethods,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.payment,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            method['name'] ?? 'unknown_method'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${'type'.tr()}: ${method['type'] ?? 'N/A'}'),
                              if (method['details'] != null)
                                Text('${'details'.tr()}: ${method['details']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () => _deletePaymentMethod(method['slug'] ?? ''),
                            tooltip: 'delete'.tr(),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePaymentMethodDialog,
        icon: const Icon(Icons.add),
        label: Text('add_payment_method'.tr()),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}
ö8*cascade08"(69af64e28f037f58004235a106ffd0818fcced0a2pfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/payment_methods_screen.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp