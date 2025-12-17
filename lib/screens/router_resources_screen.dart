import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../repositories/router_repository.dart';
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
      final repository = context.read<AppState>().routerRepository ?? RouterRepository(dio: context.read<AppState>().dio);
      // Ensure we have a valid slug/id. Use 'slug' if available (preferred), otherwise 'id'.
      final slug = widget.router['slug']?.toString() ?? widget.router['id']?.toString() ?? '';
      
      if (slug.isEmpty) throw Exception('Invalid router configuration: Missing slug/ID'); 
      
      final data = await repository.fetchRouterResources(slug);
      
      if (mounted) {
        setState(() {
          _resources = data;
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
    final data = _resources!['data'] ?? _resources;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          title: 'cpu_usage'.tr(),
          value: '${data['cpu_load'] ?? 0}%',
          icon: Icons.memory,
          color: Colors.blue,
          percentage: (data['cpu_load'] ?? 0) / 100.0,
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          title: 'memory_usage'.tr(),
          value: '${data['free_memory'] ?? 0} MB / ${data['total_memory'] ?? 0} MB',
          subtitle: 'free_memory'.tr(),
          icon: Icons.storage,
          color: Colors.orange,
          percentage: 1.0 - ((data['free_memory'] ?? 1) / (data['total_memory'] ?? 1)),
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          title: 'disk_usage'.tr(),
          value: '${data['free_hdd_space'] ?? 0} MB / ${data['total_hdd_space'] ?? 0} MB',
          subtitle: 'free_space'.tr(),
          icon: Icons.sd_storage,
          color: Colors.green,
          percentage: 1.0 - ((data['free_hdd_space'] ?? 1) / (data['total_hdd_space'] ?? 1)),
        ),
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
                _buildInfoRow('model'.tr(), data['model']?.toString() ?? 'Unknown'),
                _buildInfoRow('version'.tr(), data['version']?.toString() ?? 'Unknown'),
                _buildInfoRow('uptime'.tr(), data['uptime']?.toString() ?? 'Unknown'),
                _buildInfoRow('board_name'.tr(), data['board_name']?.toString() ?? 'Unknown'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
