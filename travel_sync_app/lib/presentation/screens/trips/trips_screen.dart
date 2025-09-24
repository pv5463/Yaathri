import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/offline_service.dart';
import '../../blocs/trip/trip_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/trip_model.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load trips when screen initializes
    context.read<TripBloc>().add(const LoadTrips(userId: 'current_user_id'));
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
                  _buildActiveTrips(),
                  _buildCompletedTrips(),
                  _buildAllTrips(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trips/start'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
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
                  'My Trips',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Track your journeys',
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
              onPressed: () => _showTripStatsDialog(),
              icon: const Icon(Icons.analytics, color: Colors.white),
              tooltip: 'Trip Statistics',
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
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'All'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SearchTextField(
        controller: _searchController,
        hintText: 'Search trips...',
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  Widget _buildActiveTrips() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TripError) {
          return _buildErrorState(state.message);
        }

        if (state is TripLoaded) {
          final activeTrips = state.trips
              .where((trip) => trip.status == TripStatus.inProgress)
              .toList();

          // In offline mode, show current trip if available
          if (OfflineService.isOfflineMode && state.currentTrip != null) {
            return Column(
              children: [
                _buildOfflineStatusBanner(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildTripCard(state.currentTrip!),
                    ],
                  ),
                ),
              ],
            );
          }

          if (activeTrips.isEmpty && !OfflineService.isOfflineMode) {
            return _buildEmptyState(
              icon: Icons.location_off,
              title: 'No active trips',
              subtitle: 'Start a new trip to begin tracking',
              actionText: 'Start Trip',
              onAction: () => context.push('/trips/start'),
            );
          }

          // Show offline message if no trips in offline mode
          if (activeTrips.isEmpty && OfflineService.isOfflineMode) {
            return Column(
              children: [
                _buildOfflineStatusBanner(),
                Expanded(
                  child: _buildEmptyState(
                    icon: Icons.offline_bolt,
                    title: 'Demo Mode',
                    subtitle: 'Limited functionality in offline mode',
                    actionText: 'View Demo Trip',
                    onAction: () {
                      // Show demo trip
                    },
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (!OfflineService.isOfflineMode) {
                context.read<TripBloc>().add(
                  const LoadTrips(userId: 'current_user_id'),
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: activeTrips.length,
              itemBuilder: (context, index) {
                return _buildTripCard(activeTrips[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOfflineStatusBanner() {
    if (!OfflineService.isOfflineMode) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Running in offline mode with demo data',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTrips() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripLoaded) {
          final completedTrips = state.trips
              .where((trip) => trip.status == TripStatus.completed)
              .toList();

          if (completedTrips.isEmpty) {
            return _buildEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No completed trips',
              subtitle: 'Your completed journeys will appear here',
              actionText: null,
              onAction: null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: completedTrips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(completedTrips[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAllTrips() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripLoaded) {
          if (state.trips.isEmpty) {
            return _buildEmptyState(
              icon: Icons.map_outlined,
              title: 'No trips yet',
              subtitle: 'Start your first journey',
              actionText: 'Start Trip',
              onAction: () => context.push('/trips/start'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: state.trips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(state.trips[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTripCard(TripModel trip) {
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
        onTap: () => context.push('/trips/details/${trip.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(trip.status),
                    style: TextStyle(
                      color: _getStatusColor(trip.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy').format(trip.startTime),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _getTravelModeIcon(trip.travelMode),
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${trip.origin} → ${trip.destination}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (trip.distance != null) ...[
                    const Icon(
                      Icons.straighten,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.distance!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (trip.duration != null) ...[
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(trip.duration!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (trip.status == TripStatus.inProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
              icon: Icons.add_location_alt,
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
            'Error loading trips',
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
              context.read<TripBloc>().add(
                const LoadTrips(userId: 'current_user_id'),
              );
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showTripStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip Statistics'),
        content: const Text(
          'View detailed statistics about your travel patterns, distances, and preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/trips/analytics');
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return AppTheme.warningColor;
      case TripStatus.inProgress:
        return AppTheme.successColor;
      case TripStatus.completed:
        return AppTheme.primaryColor;
      case TripStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return 'Planned';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getTravelModeIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.cycling:
        return Icons.directions_bike;
      case TravelMode.driving:
        return Icons.directions_car;
      case TravelMode.publicTransport:
        return Icons.directions_transit;
      case TravelMode.flight:
        return Icons.flight;
      case TravelMode.train:
        return Icons.train;
      case TravelMode.bus:
        return Icons.directions_bus;
      case TravelMode.taxi:
        return Icons.local_taxi;
      case TravelMode.other:
        return Icons.more_horiz;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }
}
