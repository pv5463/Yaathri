import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/trip_model.dart';
import '../../blocs/trip/trip_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ManualTripScreen extends StatefulWidget {
  const ManualTripScreen({super.key});

  @override
  State<ManualTripScreen> createState() => _ManualTripScreenState();
}

class _ManualTripScreenState extends State<ManualTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _purposeController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _selectedTransportMode = 'car';

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _purposeController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Manual Trip'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripCreated) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trip added successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildDateTimeSection(),
                const SizedBox(height: 24),
                _buildTripDetailsSection(),
                const SizedBox(height: 24),
                _buildTransportModeSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
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
          CustomTextField(
            controller: _fromController,
            label: 'From',
            prefixIcon: Icons.my_location,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter starting location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _toController,
            label: 'To',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter destination';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
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
            'Date & Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  label: 'Start Date',
                  icon: Icons.calendar_today,
                  value: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeField(
                  label: 'Start Time',
                  icon: Icons.access_time,
                  value: _startTime.format(context),
                  onTap: () => _selectTime(context, true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  label: 'End Date',
                  icon: Icons.calendar_today,
                  value: '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeField(
                  label: 'End Time',
                  icon: Icons.access_time,
                  value: _endTime.format(context),
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.textSecondary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
          CustomTextField(
            controller: _purposeController,
            label: 'Purpose',
            prefixIcon: Icons.description,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter trip purpose';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _distanceController,
                  label: 'Distance (km)',
                  prefixIcon: Icons.straighten,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter distance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _durationController,
                  label: 'Duration (minutes)',
                  prefixIcon: Icons.schedule,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTransportModeChip('car', Icons.directions_car, 'Car'),
              _buildTransportModeChip('bike', Icons.directions_bike, 'Bike'),
              _buildTransportModeChip('walk', Icons.directions_walk, 'Walk'),
              _buildTransportModeChip('bus', Icons.directions_bus, 'Bus'),
              _buildTransportModeChip('train', Icons.train, 'Train'),
              _buildTransportModeChip('flight', Icons.flight, 'Flight'),
              _buildTransportModeChip('other', Icons.more_horiz, 'Other'),
            ],
          ),
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

  Widget _buildNotesSection() {
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
            'Additional Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any additional details about your trip...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Save Trip',
          onPressed: state is TripLoading ? null : _handleSave,
          isLoading: state is TripLoading,
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      
      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time cannot be before start time'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      context.read<TripBloc>().add(
        CreateManualTrip(
          userId: 'current_user_id', // TODO: Get from auth state
          origin: _fromController.text,
          destination: _toController.text,
          originLat: 0.0, // TODO: Get from location service
          originLng: 0.0, // TODO: Get from location service
          destinationLat: 0.0, // TODO: Get from location service
          destinationLng: 0.0, // TODO: Get from location service
          startTime: startDateTime,
          endTime: endDateTime,
          travelMode: _getTravelModeFromString(_selectedTransportMode),
          tripType: TripType.other, // Manual trip type
          distance: double.parse(_distanceController.text),
          duration: int.parse(_durationController.text),
          notes: _notesController.text,
        ),
      );
    }
  }

  TravelMode _getTravelModeFromString(String mode) {
    switch (mode) {
      case 'walking':
        return TravelMode.walking;
      case 'cycling':
        return TravelMode.cycling;
      case 'car':
        return TravelMode.driving;
      case 'bus':
        return TravelMode.bus;
      case 'train':
        return TravelMode.train;
      case 'flight':
        return TravelMode.flight;
      default:
        return TravelMode.other;
    }
  }
}
