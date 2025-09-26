import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activity'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 24),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', true),
              _buildFilterChip('Trips', false),
              _buildFilterChip('Expenses', false),
              _buildFilterChip('Photos', false),
              _buildFilterChip('Plans', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceColor,
      side: BorderSide(
        color: isSelected 
            ? AppTheme.primaryColor 
            : AppTheme.textSecondary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildActivityItem(
              icon: _getActivityIcon(index),
              title: _getActivityTitle(index),
              subtitle: _getActivitySubtitle(index),
              time: _getActivityTime(index),
              color: _getActivityColor(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.location_on,
      Icons.receipt_long,
      Icons.photo_camera,
      Icons.calendar_today,
      Icons.directions_car,
      Icons.account_balance,
      Icons.map,
      Icons.star,
      Icons.shopping_bag,
      Icons.restaurant,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final titles = [
      'Trip to Downtown',
      'Added expense: Lunch',
      'Photo captured at Park',
      'Created new plan',
      'Started trip to Office',
      'Visited Monument',
      'Updated route',
      'Rated location',
      'Shopping expense',
      'Dinner at Restaurant',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      '8.5 km • 45 minutes',
      '\$15.50 • Food & Dining',
      'Beautiful sunset view',
      'Weekend getaway plan',
      'Morning commute',
      'Historical landmark',
      'Optimized for traffic',
      '5 stars • Great experience',
      '\$85.00 • Shopping',
      '\$32.00 • Italian cuisine',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    final times = [
      '2 hours ago',
      '3 hours ago',
      '5 hours ago',
      '1 day ago',
      '1 day ago',
      '2 days ago',
      '2 days ago',
      '3 days ago',
      '4 days ago',
      '5 days ago',
    ];
    return times[index % times.length];
  }

  Color _getActivityColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.errorColor,
      Colors.purple,
      AppTheme.secondaryColor,
      AppTheme.primaryColor,
      Colors.orange,
      AppTheme.primaryColor,
      Colors.amber,
      Colors.green,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}
