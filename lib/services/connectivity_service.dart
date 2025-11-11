import '../models/router_model.dart';

class ConnectivityService {
  Future<List<RouterModel>> getRouters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return empty list - load real data from API instead
    return [];
  }

  Future<RouterModel> createRouter(Map<String, dynamic> routerData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return RouterModel(
      id: 'router_${DateTime.now().millisecondsSinceEpoch}',
      name: routerData['name'],
      macAddress: routerData['macAddress'],
      status: 'online',
      connectedUsers: 0,
      dataUsageGB: 0,
      uptimeHours: 0,
      lastSeen: DateTime.now(),
    );
  }

  Future<void> blockDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> unblockDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> getRouterHealth(String routerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'routerId': routerId,
      'status': 'online',
      'uptime': '720 hours',
      'cpuUsage': 45.2,
      'memoryUsage': 62.8,
      'temperature': 52.5,
      'bandwidth': {
        'download': 245.6,
        'upload': 128.3,
      },
    };
  }
}
