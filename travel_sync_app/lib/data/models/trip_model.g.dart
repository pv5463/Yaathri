// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 1;

  @override
  TripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      origin: fields[2] as String,
      destination: fields[3] as String,
      originLat: fields[4] as double,
      originLng: fields[5] as double,
      destinationLat: fields[6] as double,
      destinationLng: fields[7] as double,
      startTime: fields[8] as DateTime,
      endTime: fields[9] as DateTime?,
      travelMode: fields[10] as TravelMode,
      companions: (fields[11] as List).cast<String>(),
      tripType: fields[12] as TripType,
      status: fields[13] as TripStatus,
      distance: fields[14] as double?,
      duration: fields[15] as int?,
      route: (fields[16] as List).cast<LocationPoint>(),
      mediaUrls: (fields[17] as List).cast<String>(),
      notes: fields[18] as String?,
      isAutoDetected: fields[19] as bool,
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.origin)
      ..writeByte(3)
      ..write(obj.destination)
      ..writeByte(4)
      ..write(obj.originLat)
      ..writeByte(5)
      ..write(obj.originLng)
      ..writeByte(6)
      ..write(obj.destinationLat)
      ..writeByte(7)
      ..write(obj.destinationLng)
      ..writeByte(8)
      ..write(obj.startTime)
      ..writeByte(9)
      ..write(obj.endTime)
      ..writeByte(10)
      ..write(obj.travelMode)
      ..writeByte(11)
      ..write(obj.companions)
      ..writeByte(12)
      ..write(obj.tripType)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.distance)
      ..writeByte(15)
      ..write(obj.duration)
      ..writeByte(16)
      ..write(obj.route)
      ..writeByte(17)
      ..write(obj.mediaUrls)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.isAutoDetected)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationPointAdapter extends TypeAdapter<LocationPoint> {
  @override
  final int typeId = 5;

  @override
  LocationPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationPoint(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      timestamp: fields[2] as DateTime,
      accuracy: fields[3] as double?,
      altitude: fields[4] as double?,
      speed: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationPoint obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.accuracy)
      ..writeByte(4)
      ..write(obj.altitude)
      ..writeByte(5)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TravelModeAdapter extends TypeAdapter<TravelMode> {
  @override
  final int typeId = 2;

  @override
  TravelMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TravelMode.walking;
      case 1:
        return TravelMode.cycling;
      case 2:
        return TravelMode.driving;
      case 3:
        return TravelMode.publicTransport;
      case 4:
        return TravelMode.flight;
      case 5:
        return TravelMode.train;
      case 6:
        return TravelMode.bus;
      case 7:
        return TravelMode.taxi;
      case 8:
        return TravelMode.other;
      default:
        return TravelMode.walking;
    }
  }

  @override
  void write(BinaryWriter writer, TravelMode obj) {
    switch (obj) {
      case TravelMode.walking:
        writer.writeByte(0);
        break;
      case TravelMode.cycling:
        writer.writeByte(1);
        break;
      case TravelMode.driving:
        writer.writeByte(2);
        break;
      case TravelMode.publicTransport:
        writer.writeByte(3);
        break;
      case TravelMode.flight:
        writer.writeByte(4);
        break;
      case TravelMode.train:
        writer.writeByte(5);
        break;
      case TravelMode.bus:
        writer.writeByte(6);
        break;
      case TravelMode.taxi:
        writer.writeByte(7);
        break;
      case TravelMode.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripTypeAdapter extends TypeAdapter<TripType> {
  @override
  final int typeId = 3;

  @override
  TripType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripType.business;
      case 1:
        return TripType.leisure;
      case 2:
        return TripType.commute;
      case 3:
        return TripType.shopping;
      case 4:
        return TripType.medical;
      case 5:
        return TripType.education;
      case 6:
        return TripType.social;
      case 7:
        return TripType.other;
      default:
        return TripType.business;
    }
  }

  @override
  void write(BinaryWriter writer, TripType obj) {
    switch (obj) {
      case TripType.business:
        writer.writeByte(0);
        break;
      case TripType.leisure:
        writer.writeByte(1);
        break;
      case TripType.commute:
        writer.writeByte(2);
        break;
      case TripType.shopping:
        writer.writeByte(3);
        break;
      case TripType.medical:
        writer.writeByte(4);
        break;
      case TripType.education:
        writer.writeByte(5);
        break;
      case TripType.social:
        writer.writeByte(6);
        break;
      case TripType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripStatusAdapter extends TypeAdapter<TripStatus> {
  @override
  final int typeId = 4;

  @override
  TripStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripStatus.planned;
      case 1:
        return TripStatus.inProgress;
      case 2:
        return TripStatus.completed;
      case 3:
        return TripStatus.cancelled;
      default:
        return TripStatus.planned;
    }
  }

  @override
  void write(BinaryWriter writer, TripStatus obj) {
    switch (obj) {
      case TripStatus.planned:
        writer.writeByte(0);
        break;
      case TripStatus.inProgress:
        writer.writeByte(1);
        break;
      case TripStatus.completed:
        writer.writeByte(2);
        break;
      case TripStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      originLat: (json['originLat'] as num).toDouble(),
      originLng: (json['originLng'] as num).toDouble(),
      destinationLat: (json['destinationLat'] as num).toDouble(),
      destinationLng: (json['destinationLng'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      travelMode: $enumDecode(_$TravelModeEnumMap, json['travelMode']),
      companions: (json['companions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tripType: $enumDecode(_$TripTypeEnumMap, json['tripType']),
      status: $enumDecode(_$TripStatusEnumMap, json['status']),
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      route: (json['route'] as List<dynamic>?)
              ?.map((e) => LocationPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      isAutoDetected: json['isAutoDetected'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'origin': instance.origin,
      'destination': instance.destination,
      'originLat': instance.originLat,
      'originLng': instance.originLng,
      'destinationLat': instance.destinationLat,
      'destinationLng': instance.destinationLng,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'travelMode': _$TravelModeEnumMap[instance.travelMode]!,
      'companions': instance.companions,
      'tripType': _$TripTypeEnumMap[instance.tripType]!,
      'status': _$TripStatusEnumMap[instance.status]!,
      'distance': instance.distance,
      'duration': instance.duration,
      'route': instance.route,
      'mediaUrls': instance.mediaUrls,
      'notes': instance.notes,
      'isAutoDetected': instance.isAutoDetected,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TravelModeEnumMap = {
  TravelMode.walking: 'walking',
  TravelMode.cycling: 'cycling',
  TravelMode.driving: 'driving',
  TravelMode.publicTransport: 'publicTransport',
  TravelMode.flight: 'flight',
  TravelMode.train: 'train',
  TravelMode.bus: 'bus',
  TravelMode.taxi: 'taxi',
  TravelMode.other: 'other',
};

const _$TripTypeEnumMap = {
  TripType.business: 'business',
  TripType.leisure: 'leisure',
  TripType.commute: 'commute',
  TripType.shopping: 'shopping',
  TripType.medical: 'medical',
  TripType.education: 'education',
  TripType.social: 'social',
  TripType.other: 'other',
};

const _$TripStatusEnumMap = {
  TripStatus.planned: 'planned',
  TripStatus.inProgress: 'inProgress',
  TripStatus.completed: 'completed',
  TripStatus.cancelled: 'cancelled',
};

LocationPoint _$LocationPointFromJson(Map<String, dynamic> json) =>
    LocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocationPointToJson(LocationPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'speed': instance.speed,
    };
