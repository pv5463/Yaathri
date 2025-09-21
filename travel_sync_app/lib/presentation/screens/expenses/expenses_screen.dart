import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/expense/expense_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  
  ExpenseCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load expenses when screen initializes
    context.read<ExpenseBloc>().add(const LoadExpenses(userId: 'current_user_id'));
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
            _buildFilters(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesList(),
                  _buildBudgetView(),
                  _buildAnalyticsView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
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
                  'Expenses',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Track your travel spending',
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
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _showFilterBottomSheet(),
              icon: const Icon(Icons.filter_list),
              color: AppTheme.primaryColor,
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
          Tab(text: 'Expenses'),
          Tab(text: 'Budget'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: SearchTextField(
              controller: _searchController,
              hintText: 'Search expenses...',
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedCategory != null || _selectedDateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getActiveFiltersCount()} filter(s)',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExpenseError) {
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
                  'Error loading expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
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
                    context.read<ExpenseBloc>().add(
                      const LoadExpenses(userId: 'current_user_id'),
                    );
                  },
                  width: 120,
                  height: 40,
                ),
              ],
            ),
          );
        }

        if (state is ExpenseLoaded) {
          if (state.expenses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpenseBloc>().add(
                const LoadExpenses(userId: 'current_user_id'),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: state.expenses.length,
              itemBuilder: (context, index) {
                final expense = state.expenses[index];
                return _buildExpenseCard(expense);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => context.push('/expenses/details/${expense.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (expense.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          expense.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (expense.location != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      expense.location!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (expense.sharedWith.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.group,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Shared with ${expense.sharedWith.length} people',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your travel expenses',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Add First Expense',
            onPressed: () => context.push('/expenses/add'),
            icon: Icons.add,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetView() {
    return const Center(
      child: Text(
        'Budget Management\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return const Center(
      child: Text(
        'Expense Analytics\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(_getCategoryName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
                backgroundColor: AppTheme.backgroundColor,
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Clear Filters',
                  onPressed: () {
                    _clearFilters();
                    Navigator.pop(context);
                  },
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Apply Filters',
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return const Color(0xFF9B59B6);
      case ExpenseCategory.transportation:
        return const Color(0xFF3498DB);
      case ExpenseCategory.food:
        return const Color(0xFFE67E22);
      case ExpenseCategory.entertainment:
        return const Color(0xFFE74C3C);
      case ExpenseCategory.shopping:
        return const Color(0xFFF39C12);
      case ExpenseCategory.fuel:
        return const Color(0xFF27AE60);
      default:
        return AppTheme.primaryColor;
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

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedDateRange != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDateRange = null;
    });
  }
}
