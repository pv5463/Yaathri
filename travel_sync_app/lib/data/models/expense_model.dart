import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class ExpenseModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String? tripId;
  
  @HiveField(3)
  final String title;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final double amount;
  
  @HiveField(6)
  final String currency;
  
  @HiveField(7)
  final ExpenseCategory category;
  
  @HiveField(8)
  final DateTime date;
  
  @HiveField(9)
  final String? receiptUrl;
  
  @HiveField(10)
  final List<String> sharedWith;
  
  @HiveField(11)
  final Map<String, double> splitAmounts;
  
  @HiveField(12)
  final String? location;
  
  @HiveField(13)
  final double? latitude;
  
  @HiveField(14)
  final double? longitude;
  
  @HiveField(15)
  final DateTime createdAt;
  
  @HiveField(16)
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.sharedWith = const [],
    this.splitAmounts = const {},
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    String? description,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    DateTime? date,
    String? receiptUrl,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      sharedWith: sharedWith ?? this.sharedWith,
      splitAmounts: splitAmounts ?? this.splitAmounts,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tripId,
        title,
        description,
        amount,
        currency,
        category,
        date,
        receiptUrl,
        sharedWith,
        splitAmounts,
        location,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];
}

@HiveType(typeId: 7)
enum ExpenseCategory {
  @HiveField(0)
  accommodation,
  @HiveField(1)
  transportation,
  @HiveField(2)
  food,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  shopping,
  @HiveField(5)
  fuel,
  @HiveField(6)
  parking,
  @HiveField(7)
  tolls,
  @HiveField(8)
  tickets,
  @HiveField(9)
  insurance,
  @HiveField(10)
  medical,
  @HiveField(11)
  communication,
  @HiveField(12)
  miscellaneous,
}

@HiveType(typeId: 8)
@JsonSerializable()
class BudgetModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String? tripId;
  
  @HiveField(3)
  final String title;
  
  @HiveField(4)
  final double totalBudget;
  
  @HiveField(5)
  final String currency;
  
  @HiveField(6)
  final Map<ExpenseCategory, double> categoryBudgets;
  
  @HiveField(7)
  final DateTime startDate;
  
  @HiveField(8)
  final DateTime endDate;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.title,
    required this.totalBudget,
    required this.currency,
    this.categoryBudgets = const {},
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    double? totalBudget,
    String? currency,
    Map<ExpenseCategory, double>? categoryBudgets,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tripId,
        title,
        totalBudget,
        currency,
        categoryBudgets,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}
