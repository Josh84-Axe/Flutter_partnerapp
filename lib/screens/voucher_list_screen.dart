import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/voucher_provider.dart';
import '../models/voucher_model.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VoucherProvider>();
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
              PopupMenuItem(value: 'pdf', child: Text('export_pdf'.tr())),
              PopupMenuItem(value: 'csv', child: Text('export_csv'.tr())),
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
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: voucher.isActive 
                                  ? Colors.green.withValues(alpha: 0.1) 
                                  : Colors.grey.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.vpn_key,
                                color: voucher.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                            title: Text(
                              voucher.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${'created'.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(voucher.createdAt)}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(voucher.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getStatusColor(voucher.status)),
                              ),
                              child: Text(
                                voucher.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getStatusColor(voucher.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'used': return Colors.orange;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _handleExport(String format, VoucherProvider provider) async {
    final url = provider.getExportUrl(widget.planId, format: format);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_launch_export'.tr())),
        );
      }
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
              value: quantity,
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
              }
            },
            child: Text('generate'.tr()),
          ),
        ],
      ),
    );
  }
}
