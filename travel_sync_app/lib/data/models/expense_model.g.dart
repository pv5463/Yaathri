// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 6;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      tripId: fields[2] as String?,
      title: fields[3] as String,
      description: fields[4] as String?,
      amount: fields[5] as double,
      currency: fields[6] as String,
      category: fields[7] as ExpenseCategory,
      date: fields[8] as DateTime,
      receiptUrl: fields[9] as String?,
      sharedWith: (fields[10] as List).cast<String>(),
      splitAmounts: (fields[11] as Map).cast<String, double>(),
      location: fields[12] as String?,
      latitude: fields[13] as double?,
      longitude: fields[14] as double?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.tripId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.receiptUrl)
      ..writeByte(10)
      ..write(obj.sharedWith)
      ..writeByte(11)
      ..write(obj.splitAmounts)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.longitude)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 8;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      tripId: fields[2] as String?,
      title: fields[3] as String,
      totalBudget: fields[4] as double,
      currency: fields[5] as String,
      categoryBudgets: (fields[6] as Map).cast<ExpenseCategory, double>(),
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.tripId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.totalBudget)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.categoryBudgets)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 7;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.accommodation;
      case 1:
        return ExpenseCategory.transportation;
      case 2:
        return ExpenseCategory.food;
      case 3:
        return ExpenseCategory.entertainment;
      case 4:
        return ExpenseCategory.shopping;
      case 5:
        return ExpenseCategory.fuel;
      case 6:
        return ExpenseCategory.parking;
      case 7:
        return ExpenseCategory.tolls;
      case 8:
        return ExpenseCategory.tickets;
      case 9:
        return ExpenseCategory.insurance;
      case 10:
        return ExpenseCategory.medical;
      case 11:
        return ExpenseCategory.communication;
      case 12:
        return ExpenseCategory.miscellaneous;
      default:
        return ExpenseCategory.accommodation;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.accommodation:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transportation:
        writer.writeByte(1);
        break;
      case ExpenseCategory.food:
        writer.writeByte(2);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(3);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(4);
        break;
      case ExpenseCategory.fuel:
        writer.writeByte(5);
        break;
      case ExpenseCategory.parking:
        writer.writeByte(6);
        break;
      case ExpenseCategory.tolls:
        writer.writeByte(7);
        break;
      case ExpenseCategory.tickets:
        writer.writeByte(8);
        break;
      case ExpenseCategory.insurance:
        writer.writeByte(9);
        break;
      case ExpenseCategory.medical:
        writer.writeByte(10);
        break;
      case ExpenseCategory.communication:
        writer.writeByte(11);
        break;
      case ExpenseCategory.miscellaneous:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tripId: json['tripId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      splitAmounts: (json['splitAmounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tripId': instance.tripId,
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'date': instance.date.toIso8601String(),
      'receiptUrl': instance.receiptUrl,
      'sharedWith': instance.sharedWith,
      'splitAmounts': instance.splitAmounts,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.accommodation: 'accommodation',
  ExpenseCategory.transportation: 'transportation',
  ExpenseCategory.food: 'food',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.shopping: 'shopping',
  ExpenseCategory.fuel: 'fuel',
  ExpenseCategory.parking: 'parking',
  ExpenseCategory.tolls: 'tolls',
  ExpenseCategory.tickets: 'tickets',
  ExpenseCategory.insurance: 'insurance',
  ExpenseCategory.medical: 'medical',
  ExpenseCategory.communication: 'communication',
  ExpenseCategory.miscellaneous: 'miscellaneous',
};

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tripId: json['tripId'] as String?,
      title: json['title'] as String,
      totalBudget: (json['totalBudget'] as num).toDouble(),
      currency: json['currency'] as String,
      categoryBudgets: (json['categoryBudgets'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry($enumDecode(_$ExpenseCategoryEnumMap, k),
                (e as num).toDouble()),
          ) ??
          const {},
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tripId': instance.tripId,
      'title': instance.title,
      'totalBudget': instance.totalBudget,
      'currency': instance.currency,
      'categoryBudgets': instance.categoryBudgets
          .map((k, e) => MapEntry(_$ExpenseCategoryEnumMap[k]!, e)),
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
