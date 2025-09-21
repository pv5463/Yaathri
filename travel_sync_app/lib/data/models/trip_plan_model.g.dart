// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripPlanModelAdapter extends TypeAdapter<TripPlanModel> {
  @override
  final int typeId = 9;

  @override
  TripPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripPlanModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      destination: fields[3] as String,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      description: fields[6] as String?,
      budget: fields[7] as double?,
      currency: fields[8] as String,
      status: fields[9] as TripPlanStatus,
      itinerary: (fields[10] as List).cast<ItineraryItem>(),
      sharedWith: (fields[11] as List).cast<String>(),
      tags: (fields[12] as List).cast<String>(),
      coverImageUrl: fields[13] as String?,
      preferences: (fields[14] as Map).cast<String, dynamic>(),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripPlanModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.destination)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.budget)
      ..writeByte(8)
      ..write(obj.currency)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.itinerary)
      ..writeByte(11)
      ..write(obj.sharedWith)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.coverImageUrl)
      ..writeByte(14)
      ..write(obj.preferences)
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
      other is TripPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItineraryItemAdapter extends TypeAdapter<ItineraryItem> {
  @override
  final int typeId = 11;

  @override
  ItineraryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryItem(
      id: fields[0] as String,
      title: fields[1] as String,
      dateTime: fields[2] as DateTime,
      location: fields[3] as String?,
      description: fields[4] as String?,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
      type: fields[7] as ItineraryItemType,
      estimatedCost: fields[8] as double?,
      currency: fields[9] as String?,
      duration: fields[10] as int,
      notes: (fields[11] as List).cast<String>(),
      imageUrls: (fields[12] as List).cast<String>(),
      metadata: (fields[13] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.estimatedCost)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.duration)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.imageUrls)
      ..writeByte(13)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShareInfoAdapter extends TypeAdapter<ShareInfo> {
  @override
  final int typeId = 13;

  @override
  ShareInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShareInfo(
      shareId: fields[0] as String,
      tripPlanId: fields[1] as String,
      sharedWith: (fields[2] as List).cast<String>(),
      permissions: fields[3] as SharePermissions,
      sharedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ShareInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.shareId)
      ..writeByte(1)
      ..write(obj.tripPlanId)
      ..writeByte(2)
      ..write(obj.sharedWith)
      ..writeByte(3)
      ..write(obj.permissions)
      ..writeByte(4)
      ..write(obj.sharedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShareInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripPlanStatusAdapter extends TypeAdapter<TripPlanStatus> {
  @override
  final int typeId = 10;

  @override
  TripPlanStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripPlanStatus.draft;
      case 1:
        return TripPlanStatus.confirmed;
      case 2:
        return TripPlanStatus.completed;
      case 3:
        return TripPlanStatus.cancelled;
      default:
        return TripPlanStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, TripPlanStatus obj) {
    switch (obj) {
      case TripPlanStatus.draft:
        writer.writeByte(0);
        break;
      case TripPlanStatus.confirmed:
        writer.writeByte(1);
        break;
      case TripPlanStatus.completed:
        writer.writeByte(2);
        break;
      case TripPlanStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripPlanStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItineraryItemTypeAdapter extends TypeAdapter<ItineraryItemType> {
  @override
  final int typeId = 12;

  @override
  ItineraryItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItineraryItemType.accommodation;
      case 1:
        return ItineraryItemType.transportation;
      case 2:
        return ItineraryItemType.activity;
      case 3:
        return ItineraryItemType.restaurant;
      case 4:
        return ItineraryItemType.attraction;
      case 5:
        return ItineraryItemType.meeting;
      case 6:
        return ItineraryItemType.break_time;
      case 7:
        return ItineraryItemType.other;
      default:
        return ItineraryItemType.accommodation;
    }
  }

  @override
  void write(BinaryWriter writer, ItineraryItemType obj) {
    switch (obj) {
      case ItineraryItemType.accommodation:
        writer.writeByte(0);
        break;
      case ItineraryItemType.transportation:
        writer.writeByte(1);
        break;
      case ItineraryItemType.activity:
        writer.writeByte(2);
        break;
      case ItineraryItemType.restaurant:
        writer.writeByte(3);
        break;
      case ItineraryItemType.attraction:
        writer.writeByte(4);
        break;
      case ItineraryItemType.meeting:
        writer.writeByte(5);
        break;
      case ItineraryItemType.break_time:
        writer.writeByte(6);
        break;
      case ItineraryItemType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SharePermissionsAdapter extends TypeAdapter<SharePermissions> {
  @override
  final int typeId = 14;

  @override
  SharePermissions read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SharePermissions.view;
      case 1:
        return SharePermissions.edit;
      case 2:
        return SharePermissions.admin;
      default:
        return SharePermissions.view;
    }
  }

  @override
  void write(BinaryWriter writer, SharePermissions obj) {
    switch (obj) {
      case SharePermissions.view:
        writer.writeByte(0);
        break;
      case SharePermissions.edit:
        writer.writeByte(1);
        break;
      case SharePermissions.admin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharePermissionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripPlanModel _$TripPlanModelFromJson(Map<String, dynamic> json) =>
    TripPlanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      description: json['description'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: $enumDecode(_$TripPlanStatusEnumMap, json['status']),
      itinerary: (json['itinerary'] as List<dynamic>?)
              ?.map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      coverImageUrl: json['coverImageUrl'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TripPlanModelToJson(TripPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'destination': instance.destination,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'description': instance.description,
      'budget': instance.budget,
      'currency': instance.currency,
      'status': _$TripPlanStatusEnumMap[instance.status]!,
      'itinerary': instance.itinerary,
      'sharedWith': instance.sharedWith,
      'tags': instance.tags,
      'coverImageUrl': instance.coverImageUrl,
      'preferences': instance.preferences,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TripPlanStatusEnumMap = {
  TripPlanStatus.draft: 'draft',
  TripPlanStatus.confirmed: 'confirmed',
  TripPlanStatus.completed: 'completed',
  TripPlanStatus.cancelled: 'cancelled',
};

ItineraryItem _$ItineraryItemFromJson(Map<String, dynamic> json) =>
    ItineraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      type: $enumDecode(_$ItineraryItemTypeEnumMap, json['type']),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      notes:
          (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ItineraryItemToJson(ItineraryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dateTime': instance.dateTime.toIso8601String(),
      'location': instance.location,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$ItineraryItemTypeEnumMap[instance.type]!,
      'estimatedCost': instance.estimatedCost,
      'currency': instance.currency,
      'duration': instance.duration,
      'notes': instance.notes,
      'imageUrls': instance.imageUrls,
      'metadata': instance.metadata,
    };

const _$ItineraryItemTypeEnumMap = {
  ItineraryItemType.accommodation: 'accommodation',
  ItineraryItemType.transportation: 'transportation',
  ItineraryItemType.activity: 'activity',
  ItineraryItemType.restaurant: 'restaurant',
  ItineraryItemType.attraction: 'attraction',
  ItineraryItemType.meeting: 'meeting',
  ItineraryItemType.break_time: 'break_time',
  ItineraryItemType.other: 'other',
};

ShareInfo _$ShareInfoFromJson(Map<String, dynamic> json) => ShareInfo(
      shareId: json['shareId'] as String,
      tripPlanId: json['tripPlanId'] as String,
      sharedWith: (json['sharedWith'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      permissions: $enumDecode(_$SharePermissionsEnumMap, json['permissions']),
      sharedAt: DateTime.parse(json['sharedAt'] as String),
    );

Map<String, dynamic> _$ShareInfoToJson(ShareInfo instance) => <String, dynamic>{
      'shareId': instance.shareId,
      'tripPlanId': instance.tripPlanId,
      'sharedWith': instance.sharedWith,
      'permissions': _$SharePermissionsEnumMap[instance.permissions]!,
      'sharedAt': instance.sharedAt.toIso8601String(),
    };

const _$SharePermissionsEnumMap = {
  SharePermissions.view: 'view',
  SharePermissions.edit: 'edit',
  SharePermissions.admin: 'admin',
};
