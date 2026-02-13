import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/voucher_provider.dart';
import '../providers/split/network_provider.dart';
import '../services/voucher_export_service.dart';
import '../widgets/voucher_ticket_card.dart';

class VoucherListScreen extends StatefulWidget {
  final String planId;
  final String planName;

  const VoucherListScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  bool _showUsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().loadVouchers(widget.planId);
      // Ensure plans are loaded to display features on tickets
      final networkProvider = context.read<NetworkProvider>();
      if (networkProvider.plans.isEmpty) {
        networkProvider.loadPlans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VoucherProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    
    // Find the full plan model to get features (data limit, devices, etc.)
    final planModel = networkProvider.plans.cast<dynamic>().firstWhere(
      (p) => p.id.toString() == widget.planId || p.slug == widget.planId,
      orElse: () => null,
    );

    final vouchers = provider.getVouchersForPlan(widget.planId).where((v) {
      return _showUsed ? true : v.isActive;
    }).toList();
    
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.planName} - ${'vouchers'.tr()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadVouchers(widget.planId),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleExport(value, provider),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'local_pdf', child: Text('Download PDF (Local)')),
              PopupMenuItem(value: 'local_csv', child: Text('Download CSV (Local)')),
            ],
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'total'.tr(),
                    provider.getVouchersForPlan(widget.planId).length.toString(),
                    Icons.confirmation_number,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'active'.tr(),
                    provider.getVouchersForPlan(widget.planId).where((v) => v.isActive).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          SwitchListTile(
            title: Text('show_used_vouchers'.tr()),
            value: _showUsed,
            onChanged: (val) => setState(() => _showUsed = val),
          ),

          const Divider(),

          // Voucher List
          Expanded(
            child: provider.isLoading && vouchers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : vouchers.isEmpty
                    ? Center(
                        child: Text(
                          _showUsed ? 'no_vouchers_found'.tr() : 'no_active_vouchers'.tr(),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          return VoucherTicketCard(
                            voucher: voucher,
                            plan: planModel,
                            onMessage: (msg) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(context, provider),
        label: Text('generate_vouchers'.tr()),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(String format, VoucherProvider provider) async {
    final vouchers = provider.getVouchersForPlan(widget.planId);
    
    if (format == 'local_pdf') {
      await VoucherExportService.exportToPDF(vouchers, widget.planName);
      return;
    }
    
    if (format == 'local_csv') {
      await VoucherExportService.exportToCSV(vouchers, widget.planName);
      return;
    }
  }

  void _showGenerateDialog(BuildContext context, VoucherProvider provider) {
    int quantity = 10;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('generate_vouchers'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('how_many_vouchers'.tr()),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: quantity,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [10, 20, 50, 100].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value ${'codes'.tr()}'),
                );
              }).toList(),
              onChanged: (val) => quantity = val ?? 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.generateVouchers(widget.planId, quantity);
              if (provider.error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error!)),
                );
              } else if (mounted) {
                _showSuccessDialog(quantity);
              }
            },
            child: Text('generate'.tr()),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessDialog(int quantity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Success!'),
        content: Text(
          '$quantity vouchers have been generated successfully.\n\nWould you like to download them now?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _handleExport('local_pdf', context.read<VoucherProvider>());
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }
}
