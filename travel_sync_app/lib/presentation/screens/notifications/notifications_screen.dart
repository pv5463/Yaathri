import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection('Today', _getTodayNotifications()),
            const SizedBox(height: 24),
            _buildNotificationSection('Yesterday', _getYesterdayNotifications()),
            const SizedBox(height: 24),
            _buildNotificationSection('Earlier', _getEarlierNotifications()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<NotificationItem> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationItem(notification);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? AppTheme.surfaceColor : AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? AppTheme.textSecondary.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color: notification.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationItem> _getTodayNotifications() {
    return [
      NotificationItem(
        icon: Icons.location_on,
        title: 'Trip Completed',
        message: 'Your trip to Downtown has been completed. Total distance: 8.5 km',
        time: '2 hours ago',
        color: AppTheme.successColor,
        isRead: false,
      ),
      NotificationItem(
        icon: Icons.account_balance,
        title: 'Monument Discovered',
        message: 'You discovered Red Fort! Check out the details and add it to your collection.',
        time: '4 hours ago',
        color: Colors.orange,
        isRead: false,
      ),
      NotificationItem(
        icon: Icons.receipt_long,
        title: 'Expense Added',
        message: 'New expense of \$15.50 added for lunch at Italian Restaurant',
        time: '6 hours ago',
        color: AppTheme.errorColor,
        isRead: true,
      ),
    ];
  }

  List<NotificationItem> _getYesterdayNotifications() {
    return [
      NotificationItem(
        icon: Icons.calendar_today,
        title: 'Trip Reminder',
        message: 'Don\'t forget about your planned trip to the mountains tomorrow!',
        time: 'Yesterday, 6:00 PM',
        color: AppTheme.primaryColor,
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.photo_camera,
        title: 'Photo Memory',
        message: 'Your photo from Central Park has been added to your travel memories',
        time: 'Yesterday, 2:30 PM',
        color: Colors.purple,
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.star,
        title: 'Achievement Unlocked',
        message: 'Congratulations! You\'ve completed 10 trips this month',
        time: 'Yesterday, 10:00 AM',
        color: Colors.amber,
        isRead: true,
      ),
    ];
  }

  List<NotificationItem> _getEarlierNotifications() {
    return [
      NotificationItem(
        icon: Icons.map,
        title: 'Route Optimized',
        message: 'We found a better route for your upcoming trip that saves 15 minutes',
        time: '2 days ago',
        color: AppTheme.primaryColor,
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.group,
        title: 'Trip Shared',
        message: 'John shared their weekend getaway plan with you',
        time: '3 days ago',
        color: AppTheme.secondaryColor,
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.trending_up,
        title: 'Monthly Report',
        message: 'Your travel summary for last month is ready to view',
        time: '5 days ago',
        color: AppTheme.successColor,
        isRead: true,
      ),
    ];
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    this.isRead = false,
  });
}
