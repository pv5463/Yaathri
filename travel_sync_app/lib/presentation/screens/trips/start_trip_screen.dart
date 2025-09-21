import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/trip_model.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/trip/trip_bloc.dart';
import '../../widgets/custom_button.dart';

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({super.key});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  final _destinationController = TextEditingController();
  final _purposeController = TextEditingController();
  String _selectedTransportMode = 'car';
  bool _autoDetectMode = true;

  @override
  void dispose() {
    _destinationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Trip'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripStarted) {
            context.go('/trips/details/${state.trip.id}');
          } else if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildTripDetailsSection(),
              const SizedBox(height: 24),
              _buildTransportModeSection(),
              const SizedBox(height: 24),
              _buildTrackingOptionsSection(),
              const SizedBox(height: 32),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        String currentLocation = 'Getting location...';
        if (state is LocationLoaded) {
          currentLocation = 'Current Location'; // TODO: Get address from location
        }

        return Container(
          padding: const EdgeInsets.all(20),
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
                'Trip Route',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildLocationRow(
                icon: Icons.my_location,
                label: 'From',
                value: currentLocation,
                isEditable: false,
              ),
              const SizedBox(height: 12),
              Container(
                width: 2,
                height: 20,
                margin: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                icon: Icons.location_on,
                label: 'To',
                value: _destinationController.text.isEmpty 
                    ? 'Enter destination' 
                    : _destinationController.text,
                isEditable: true,
                controller: _destinationController,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    TextEditingController? controller,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (isEditable)
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter destination',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (isEditable)
          IconButton(
            onPressed: () {
              // Open map picker
            },
            icon: const Icon(
              Icons.map,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildTripDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _purposeController,
            decoration: InputDecoration(
              labelText: 'Trip Purpose (Optional)',
              hintText: 'e.g., Work, Shopping, Leisure',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportModeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transportation Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-detect mode'),
            subtitle: const Text('Automatically detect how you\'re traveling'),
            value: _autoDetectMode,
            onChanged: (value) {
              setState(() {
                _autoDetectMode = value;
              });
            },
            activeThumbColor: AppTheme.primaryColor,
          ),
          if (!_autoDetectMode) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTransportModeChip('car', Icons.directions_car, 'Car'),
                _buildTransportModeChip('bike', Icons.directions_bike, 'Bike'),
                _buildTransportModeChip('walk', Icons.directions_walk, 'Walk'),
                _buildTransportModeChip('bus', Icons.directions_bus, 'Bus'),
                _buildTransportModeChip('train', Icons.train, 'Train'),
                _buildTransportModeChip('other', Icons.more_horiz, 'Other'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransportModeChip(String mode, IconData icon, String label) {
    final isSelected = _selectedTransportMode == mode;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTransportMode = mode;
        });
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : AppTheme.textSecondary,
      ),
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

  Widget _buildTrackingOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrackingOption(
            icon: Icons.location_on,
            title: 'High Accuracy GPS',
            subtitle: 'More precise tracking, uses more battery',
            isEnabled: true,
          ),
          _buildTrackingOption(
            icon: Icons.camera_alt,
            title: 'Auto-capture Photos',
            subtitle: 'Take photos at interesting locations',
            isEnabled: false,
          ),
          _buildTrackingOption(
            icon: Icons.notifications,
            title: 'Trip Notifications',
            subtitle: 'Get updates about your journey',
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
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
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle option toggle
            },
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Start Trip',
          onPressed: state is TripLoading ? null : _handleStartTrip,
          isLoading: state is TripLoading,
          icon: Icons.play_arrow,
        );
      },
    );
  }

  void _handleStartTrip() {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(
      StartTrip(
        userId: 'current_user_id', // TODO: Get from auth state
        destination: _destinationController.text,
        travelMode: TravelMode.other, // TODO: Map from _selectedTransportMode
        tripType: TripType.other, // TODO: Map from purpose
        isAutoDetected: _autoDetectMode,
      ),
    );
  }
}
