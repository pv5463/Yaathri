import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/planning/planning_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/trip_plan_model.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load trip plans when screen initializes
    context.read<PlanningBloc>().add(const LoadTripPlans(userId: 'current_user_id'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingPlans(),
                  _buildDraftPlans(),
                  _buildCompletedPlans(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/planning/create'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Planning',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Plan your perfect journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _showQuickPlanDialog(),
              icon: const Icon(Icons.flash_on, color: Colors.white),
              tooltip: 'Quick Plan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Drafts'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SearchTextField(
        controller: _searchController,
        hintText: 'Search trip plans...',
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  Widget _buildUpcomingPlans() {
    return BlocBuilder<PlanningBloc, PlanningState>(
      builder: (context, state) {
        if (state is PlanningLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlanningError) {
          return _buildErrorState(state.message);
        }

        if (state is PlanningLoaded) {
          final upcomingPlans = state.tripPlans
              .where((plan) => plan.status == TripPlanStatus.confirmed)
              .toList();

          if (upcomingPlans.isEmpty) {
            return _buildEmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No upcoming trips',
              subtitle: 'Start planning your next adventure',
              actionText: 'Create Trip Plan',
              onAction: () => context.push('/planning/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlanningBloc>().add(
                const LoadTripPlans(userId: 'current_user_id'),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: upcomingPlans.length,
              itemBuilder: (context, index) {
                return _buildTripPlanCard(upcomingPlans[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDraftPlans() {
    return BlocBuilder<PlanningBloc, PlanningState>(
      builder: (context, state) {
        if (state is PlanningLoaded) {
          final draftPlans = state.tripPlans
              .where((plan) => plan.status == TripPlanStatus.draft)
              .toList();

          if (draftPlans.isEmpty) {
            return _buildEmptyState(
              icon: Icons.edit_outlined,
              title: 'No draft plans',
              subtitle: 'Save your trip ideas as drafts',
              actionText: 'Start Planning',
              onAction: () => context.push('/planning/create'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: draftPlans.length,
            itemBuilder: (context, index) {
              return _buildTripPlanCard(draftPlans[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCompletedPlans() {
    return BlocBuilder<PlanningBloc, PlanningState>(
      builder: (context, state) {
        if (state is PlanningLoaded) {
          final completedPlans = state.tripPlans
              .where((plan) => plan.status == TripPlanStatus.completed)
              .toList();

          if (completedPlans.isEmpty) {
            return _buildEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No completed trips',
              subtitle: 'Your travel memories will appear here',
              actionText: null,
              onAction: null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: completedPlans.length,
            itemBuilder: (context, index) {
              return _buildTripPlanCard(completedPlans[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTripPlanCard(TripPlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => context.push('/planning/itinerary/${plan.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    _getDestinationColor(plan.destination),
                    _getDestinationColor(plan.destination).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(plan.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(plan.status),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          plan.destination,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM dd').format(plan.startDate)} - ${DateFormat('MMM dd, yyyy').format(plan.endDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${plan.endDate.difference(plan.startDate).inDays + 1} days',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  if (plan.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      plan.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.location_on,
                        label: '${plan.itinerary.length} places',
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      if (plan.budget != null)
                        _buildInfoChip(
                          icon: Icons.account_balance_wallet,
                          label: '\$${plan.budget!.toStringAsFixed(0)}',
                          color: AppTheme.successColor,
                        ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 32),
            CustomButton(
              text: actionText,
              onPressed: onAction,
              icon: Icons.add,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: () {
              context.read<PlanningBloc>().add(
                const LoadTripPlans(userId: 'current_user_id'),
              );
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showQuickPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Plan'),
        content: const Text(
          'Create a quick trip plan with AI assistance based on your preferences and budget.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/planning/create?quick=true');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Color _getDestinationColor(String destination) {
    // Simple hash-based color generation
    final hash = destination.hashCode;
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF50C878),
      const Color(0xFF9B59B6),
      const Color(0xFFE67E22),
      const Color(0xFFE74C3C),
      const Color(0xFF3498DB),
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getStatusText(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return 'Draft';
      case TripPlanStatus.confirmed:
        return 'Confirmed';
      case TripPlanStatus.completed:
        return 'Completed';
      case TripPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return AppTheme.warningColor;
      case TripPlanStatus.confirmed:
        return AppTheme.primaryColor;
      case TripPlanStatus.completed:
        return AppTheme.successColor;
      case TripPlanStatus.cancelled:
        return AppTheme.errorColor;
    }
  }
}

