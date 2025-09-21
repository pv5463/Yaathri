import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/expense_model.dart';
import '../../blocs/expense/expense_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? tripId;

  const AddExpenseScreen({super.key, this.tripId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ExpenseCategory _selectedCategory = ExpenseCategory.miscellaneous;
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  final List<String> _sharedWith = [];
  String? _receiptImagePath;
  Position? _currentLocation;
  bool _isLoadingLocation = false;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _getCurrentLocation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense added successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.pop();
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 32),
                    _buildCategorySelection(),
                    const SizedBox(height: 32),
                    _buildAmountAndCurrency(),
                    const SizedBox(height: 32),
                    _buildDateSelection(),
                    const SizedBox(height: 32),
                    _buildLocationSection(),
                    const SizedBox(height: 32),
                    _buildReceiptSection(),
                    const SizedBox(height: 32),
                    _buildSharingSection(),
                    const SizedBox(height: 48),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _titleController,
          label: 'Title',
          hintText: 'Enter expense title',
          prefixIcon: Icons.receipt_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _descriptionController,
          label: 'Description (Optional)',
          hintText: 'Add more details about this expense',
          prefixIcon: Icons.notes_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ExpenseCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textSecondary.withOpacity(0.2),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountAndCurrency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE1E8ED),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(
                          currency,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE1E8ED),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (_isLoadingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('Use Current'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _locationController,
          label: 'Location (Optional)',
          hintText: 'Where did you spend this?',
          prefixIcon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receipt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickReceiptImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: _receiptImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _receiptImagePath!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 32,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add receipt photo',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Sharing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addPersonToShare,
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add Person'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_sharedWith.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 32,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No one added yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sharedWith.map((person) {
              return Chip(
                label: Text(person),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _sharedWith.remove(person);
                  });
                },
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                deleteIconColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Save Expense',
          onPressed: _saveExpense,
          isLoading: state is ExpenseLoading,
          icon: Icons.save,
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.locality}';
        
        setState(() {
          _locationController.text = address;
          _currentLocation = position;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get current location'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _receiptImagePath = image.path;
      });
    }
  }

  void _addPersonToShare() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Person'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter name or email',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _sharedWith.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // Replace with actual user ID
        tripId: widget.tripId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        category: _selectedCategory,
        date: _selectedDate,
        receiptUrl: _receiptImagePath,
        sharedWith: _sharedWith,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        latitude: _currentLocation?.latitude,
        longitude: _currentLocation?.longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ExpenseBloc>().add(CreateExpense(expense: expense));
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.parking:
        return Icons.local_parking;
      case ExpenseCategory.tolls:
        return Icons.toll;
      case ExpenseCategory.tickets:
        return Icons.confirmation_number;
      case ExpenseCategory.medical:
        return Icons.medical_services;
      default:
        return Icons.receipt;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    return category.name.substring(0, 1).toUpperCase() + 
           category.name.substring(1);
  }
}
