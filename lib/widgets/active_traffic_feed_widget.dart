import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/family_models.dart';

class ActiveTrafficFeedWidget extends StatefulWidget {
  final List<FamilyDevice> devices;

  const ActiveTrafficFeedWidget({
    super.key,
    required this.devices,
  });

  @override
  State<ActiveTrafficFeedWidget> createState() => _ActiveTrafficFeedWidgetState();
}

class _ActiveTrafficFeedWidgetState extends State<ActiveTrafficFeedWidget> {
  Timer? _ticker;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _tickCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Simulated dynamic speeds based on device status and tick count
  double _getDownloadSpeed(FamilyDevice device) {
    if (!device.isOnline || device.isPaused) return 0.0;
    final hash = device.id.hashCode + _tickCount;
    return ((hash % 45) + 5) / 10.0; // 0.5 - 5.0 Mbps
  }

  double _getUploadSpeed(FamilyDevice device) {
    if (!device.isOnline || device.isPaused) return 0.0;
    final hash = (device.id.hashCode * 3) + _tickCount;
    return ((hash % 20) + 1) / 10.0; // 0.1 - 2.0 Mbps
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onlineDevices = widget.devices.where((d) => d.isOnline && !d.isPaused).toList();
    final totalDown = onlineDevices.fold<double>(0.0, (sum, d) => sum + _getDownloadSpeed(d));
    final totalUp = onlineDevices.fold<double>(0.0, (sum, d) => sum + _getUploadSpeed(d));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.swap_vert_rounded, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Traffic Feed',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Real-time Bandwidth Activity',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scaleXY(begin: 0.8, end: 1.3, duration: 800.ms),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Aggregate Speed Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Download', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                            Text(
                              '${totalDown.toStringAsFixed(1)} Mbps',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Upload', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                            Text(
                              '${totalUp.toStringAsFixed(1)} Mbps',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.devices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
              const SizedBox(height: 12),
              Column(
                children: widget.devices.take(4).map((device) {
                  final down = _getDownloadSpeed(device);
                  final up = _getUploadSpeed(device);
                  final isOnline = device.isOnline && !device.isPaused;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: device.isPaused
                                ? colorScheme.error
                                : (device.isOnline ? Colors.green : Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            device.deviceName,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOnline) ...[
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, size: 12, color: Colors.green),
                              Text('${down.toStringAsFixed(1)} MB/s', style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_upward, size: 12, color: Colors.blue),
                              Text('${up.toStringAsFixed(1)} MB/s', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ] else ...[
                          Text(
                            device.isPaused ? 'Paused' : 'Idle / Offline',
                            style: TextStyle(
                              fontSize: 11,
                              color: device.isPaused ? colorScheme.error : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
