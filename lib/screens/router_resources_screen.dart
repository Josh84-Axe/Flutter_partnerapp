import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/network_provider.dart';
import '../utils/error_message_helper.dart';

class RouterResourcesScreen extends StatefulWidget {
  final Map<String, dynamic> router;

  const RouterResourcesScreen({super.key, required this.router});

  @override
  State<RouterResourcesScreen> createState() => _RouterResourcesScreenState();
}

class _RouterResourcesScreenState extends State<RouterResourcesScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _resources;
  int _activeSessionsCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<NetworkProvider>();
      final slug = widget.router['slug']?.toString() ?? widget.router['id']?.toString() ?? '';
      final routerName = widget.router['name']?.toString() ?? '';
      final routerIp = widget.router['ip_address']?.toString() ?? '';
      
      if (slug.isEmpty && routerIp.isEmpty) throw Exception('Invalid router config: Missing ID/IP'); 
      
      final resourcesPromise = provider.fetchRouterResources(slug);
      final sessionsPromise = provider.fetchActiveSessionsGlobal();
      
      final results = await Future.wait([resourcesPromise, sessionsPromise]);
      
      final allSessions = results[1] as List<dynamic>? ?? [];
      final routerSessions = allSessions.where((s) {
        final sName = s['router_name']?.toString().toLowerCase() ?? '';
        final sIp = s['router_ip']?.toString() ?? '';
        
        // Exact IP match is most reliable
        if (routerIp.isNotEmpty && sIp == routerIp) return true;
        // Fallback to name/slug contains
        if (routerName.isNotEmpty && sName.contains(routerName.toLowerCase())) return true;
        if (slug.isNotEmpty && sName.contains(slug.toLowerCase())) return true;
        
        return false;
      }).toList();

      if (mounted) {
        setState(() {
          _resources = results[0] as Map<String, dynamic>?;
          _activeSessionsCount = routerSessions.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorMessageHelper.getUserFriendlyMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('system_resources'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchResources,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _fetchResources,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : _buildResourcesList(),
    );
  }

  Widget _buildResourcesList() {
    if (_resources == null || _resources!.isEmpty) {
      return Center(child: Text('no_data_available'.tr()));
    }
    
    // Extract nested data if necessary, based on API response structure
    // Backend may wrap MikroTik response in data, results, or directly under resource keys
    final data = _resources!['data'] ?? 
                 _resources!['results'] ?? 
                 _resources!['resource'] ?? 
                 _resources!['system-resource'] ?? 
                 _resources!;

    // Robust field extraction helper (handles both MikroTik hyphens and project underscores)
    dynamic getField(String primaryKey, [String? fallbackKey]) {
      return data[primaryKey] ?? (fallbackKey != null ? data[fallbackKey] : null);
    }

    final cpuLoad = double.tryParse(getField('cpu-load', 'cpu_load')?.toString() ?? '0') ?? 0.0;
    
    final freeMemory = double.tryParse(getField('free-memory', 'free_memory')?.toString() ?? '0') ?? 0.0;
    final totalMemory = double.tryParse(getField('total-memory', 'total_memory')?.toString() ?? '1') ?? 1.0;
    
    final freeDisk = double.tryParse(getField('free-hdd-space', 'free_hdd_space')?.toString() ?? '0') ?? 0.0;
    final totalDisk = double.tryParse(getField('total-hdd-space', 'total_hdd_space')?.toString() ?? '1') ?? 1.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          title: 'cpu_usage'.tr(),
          value: '${cpuLoad.toStringAsFixed(1)}%',
          icon: Icons.memory,
          color: Colors.blue,
          percentage: cpuLoad / 100.0,
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          title: 'memory_usage'.tr(),
          value: '${(100.0 - (freeMemory / totalMemory * 100.0)).toStringAsFixed(1)}%',
          subtitle: '${freeMemory.toStringAsFixed(0)} MB / ${totalMemory.toStringAsFixed(0)} MB',
          icon: Icons.storage,
          color: Colors.orange,
          percentage: 1.0 - (freeMemory / totalMemory),
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          title: 'disk_usage'.tr(),
          value: '${(100.0 - (freeDisk / totalDisk * 100.0)).toStringAsFixed(1)}%',
          subtitle: '${freeDisk.toStringAsFixed(0)} MB / ${totalDisk.toStringAsFixed(0)} MB',
          icon: Icons.sd_storage,
          color: Colors.green,
          percentage: 1.0 - (freeDisk / totalDisk),
        ),
        const SizedBox(height: 16),
        _buildActiveSessionsCard(),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'device_info'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                _buildInfoRow('model'.tr(), getField('model')?.toString() ?? 'unknown'.tr()),
                _buildInfoRow('version'.tr(), getField('version')?.toString() ?? 'unknown'.tr()),
                _buildInfoRow('uptime'.tr(), getField('uptime')?.toString() ?? 'unknown'.tr()),
                _buildInfoRow('board_name'.tr(), getField('board-name', 'board_name')?.toString() ?? 'unknown'.tr()),
                _buildInfoRow('cpu_count'.tr(), getField('cpu-count', 'cpu_count')?.toString() ?? 'not_available'.tr()),
                _buildInfoRow('frequency'.tr(), '${getField('cpu-frequency', 'cpu_frequency')?.toString() ?? 'not_available'.tr()} MHz'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required double percentage,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.people, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'active_sessions'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_activeSessionsCount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(value),
        ],
      ),
    );
  }
}
