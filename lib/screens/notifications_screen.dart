import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/notification_model.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifications = appState.notifications;

    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final now = DateTime.now();

    for (final notification in notifications) {
      final diff = now.difference(notification.timestamp);
      if (diff.inHours < 24) {
        today.add(notification);
      } else if (diff.inHours < 48) {
        yesterday.add(notification);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => appState.markAllNotificationsAsRead(),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: AppTheme.pureWhite),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                if (today.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Today'),
                  ...today.map((n) => _buildNotificationItem(context, n, appState)),
                ],
                if (yesterday.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Yesterday'),
                  ...yesterday.map((n) => _buildNotificationItem(context, n, appState)),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    AppState appState,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => appState.dismissNotification(notification.id),
      background: Container(
        color: AppTheme.errorRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: AppTheme.pureWhite),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : AppTheme.primaryGreen.withOpacity(0.05),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => appState.dismissNotification(notification.id),
          ),
          onTap: () {
            if (!notification.isRead) {
              appState.markNotificationAsRead(notification.id);
            }
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'user':
        return Icons.person_add;
      case 'payment':
        return Icons.paid;
      case 'router':
        return Icons.wifi_off;
      case 'system':
        return Icons.system_update;
      case 'report':
        return Icons.assessment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'user':
        return AppTheme.primaryGreen;
      case 'payment':
        return AppTheme.successGreen;
      case 'router':
        return AppTheme.errorRed;
      case 'system':
        return AppTheme.warningAmber;
      case 'report':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}
