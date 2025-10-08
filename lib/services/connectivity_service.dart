import '../models/router_model.dart';

class ConnectivityService {
  Future<List<RouterModel>> getRouters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      RouterModel(
        id: 'router_001',
        name: 'Main Gateway',
        macAddress: '00:1A:2B:3C:4D:5E',
        status: 'online',
        connectedUsers: 24,
        dataUsageGB: 456.8,
        uptimeHours: 720,
        lastSeen: DateTime.now(),
      ),
      RouterModel(
        id: 'router_002',
        name: 'Secondary Access Point',
        macAddress: '00:1A:2B:3C:4D:5F',
        status: 'online',
        connectedUsers: 18,
        dataUsageGB: 328.5,
        uptimeHours: 698,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RouterModel(
        id: 'router_003',
        name: 'Backup Router',
        macAddress: '00:1A:2B:3C:4D:60',
        status: 'offline',
        connectedUsers: 0,
        dataUsageGB: 0,
        uptimeHours: 0,
        lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
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
