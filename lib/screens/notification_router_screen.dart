import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';
import '../models/notification_model.dart';

class NotificationRouterScreen extends StatefulWidget {
  const NotificationRouterScreen({super.key});

  @override
  State<NotificationRouterScreen> createState() => _NotificationRouterScreenState();
}

class _NotificationRouterScreenState extends State<NotificationRouterScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      type: 'critical',
      title: 'Critical: Router Offline!',
      message: 'Lobby Router (192.168.1.1) is currently offline. Please check its status.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      type: 'user',
      title: 'New User Registered',
      message: 'Alex Morgan has joined your network.',
      timestamp: DateTime.now().subtract(const Duration(hours: 7, minutes: 30)),
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      type: 'payment',
      title: 'Payment Received',
      message: 'Received \$250 from UserX.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6, minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: '4',
      type: 'system',
      title: 'System Update',
      message: 'A new platform update is available.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 45)),
      isRead: false,
    ),
    NotificationModel(
      id: '5',
      type: 'report',
      title: 'User Activity Report',
      message: 'Your weekly report is ready to view.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4, minutes: 10)),
      isRead: false,
    ),
  ];

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('all_notifications_marked_read'.tr()),
      ),
    );
  }

  List<NotificationModel> get _criticalNotifications {
    return _notifications.where((n) => n.type == 'critical').toList();
  }

  List<NotificationModel> get _todayNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      final difference = now.difference(n.timestamp);
      return difference.inHours < 24 && n.type != 'critical';
    }).toList();
  }

  List<NotificationModel> get _yesterdayNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      final difference = now.difference(n.timestamp);
      return difference.inHours >= 24 && difference.inDays < 2;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'mark_all_read'.tr(),
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_criticalNotifications.isNotEmpty) ...[
            Text(
              'critical_alerts'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._criticalNotifications.map((notification) =>
              _buildNotificationCard(notification, isCritical: true)),
            const SizedBox(height: 24),
          ],
          if (_todayNotifications.isNotEmpty) ...[
            Text(
              'today'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._todayNotifications.map((notification) =>
              _buildNotificationCard(notification)),
            const SizedBox(height: 24),
          ],
          if (_yesterdayNotifications.isNotEmpty) ...[
            Text(
              'yesterday'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._yesterdayNotifications.map((notification) =>
              _buildNotificationCard(notification)),
          ],
          if (_notifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_notifications'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, {bool isCritical = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = isCritical ? colorScheme.error : colorScheme.primary;
    final backgroundColor = isCritical 
        ? colorScheme.errorContainer
        : colorScheme.surface;
    final borderColor = isCritical ? colorScheme.error : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isCritical
            ? Border(left: BorderSide(color: borderColor, width: 4))
            : null,
        boxShadow: [
          if (!isCritical)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isCritical ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isCritical ? AppTheme.errorRed : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => _dismissNotification(notification.id),
            color: AppTheme.textLight,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.warning;
      case 'user':
        return Icons.person_add;
      case 'payment':
        return Icons.payments;
      case 'system':
        return Icons.system_update;
      case 'report':
        return Icons.assessment;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
