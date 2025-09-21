import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class TripModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String origin;
  
  @HiveField(3)
  final String destination;
  
  @HiveField(4)
  final double originLat;
  
  @HiveField(5)
  final double originLng;
  
  @HiveField(6)
  final double destinationLat;
  
  @HiveField(7)
  final double destinationLng;
  
  @HiveField(8)
  final DateTime startTime;
  
  @HiveField(9)
  final DateTime? endTime;
  
  @HiveField(10)
  final TravelMode travelMode;
  
  @HiveField(11)
  final List<String> companions;
  
  @HiveField(12)
  final TripType tripType;
  
  @HiveField(13)
  final TripStatus status;
  
  @HiveField(14)
  final double? distance;
  
  @HiveField(15)
  final int? duration;
  
  @HiveField(16)
  final List<LocationPoint> route;
  
  @HiveField(17)
  final List<String> mediaUrls;
  
  @HiveField(18)
  final String? notes;
  
  @HiveField(19)
  final bool isAutoDetected;
  
  @HiveField(20)
  final DateTime createdAt;
  
  @HiveField(21)
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.userId,
    required this.origin,
    required this.destination,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.startTime,
    this.endTime,
    required this.travelMode,
    this.companions = const [],
    required this.tripType,
    required this.status,
    this.distance,
    this.duration,
    this.route = const [],
    this.mediaUrls = const [],
    this.notes,
    this.isAutoDetected = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  TripModel copyWith({
    String? id,
    String? userId,
    String? origin,
    String? destination,
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    DateTime? startTime,
    DateTime? endTime,
    TravelMode? travelMode,
    List<String>? companions,
    TripType? tripType,
    TripStatus? status,
    double? distance,
    int? duration,
    List<LocationPoint>? route,
    List<String>? mediaUrls,
    String? notes,
    bool? isAutoDetected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      travelMode: travelMode ?? this.travelMode,
      companions: companions ?? this.companions,
      tripType: tripType ?? this.tripType,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      route: route ?? this.route,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      notes: notes ?? this.notes,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        origin,
        destination,
        originLat,
        originLng,
        destinationLat,
        destinationLng,
        startTime,
        endTime,
        travelMode,
        companions,
        tripType,
        status,
        distance,
        duration,
        route,
        mediaUrls,
        notes,
        isAutoDetected,
        createdAt,
        updatedAt,
      ];
}

@HiveType(typeId: 2)
enum TravelMode {
  @HiveField(0)
  walking,
  @HiveField(1)
  cycling,
  @HiveField(2)
  driving,
  @HiveField(3)
  publicTransport,
  @HiveField(4)
  flight,
  @HiveField(5)
  train,
  @HiveField(6)
  bus,
  @HiveField(7)
  taxi,
  @HiveField(8)
  other,
}

@HiveType(typeId: 3)
enum TripType {
  @HiveField(0)
  business,
  @HiveField(1)
  leisure,
  @HiveField(2)
  commute,
  @HiveField(3)
  shopping,
  @HiveField(4)
  medical,
  @HiveField(5)
  education,
  @HiveField(6)
  social,
  @HiveField(7)
  other,
}

@HiveType(typeId: 4)
enum TripStatus {
  @HiveField(0)
  planned,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 5)
@JsonSerializable()
class LocationPoint extends Equatable {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final double? accuracy;
  
  @HiveField(4)
  final double? altitude;
  
  @HiveField(5)
  final double? speed;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.speed,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPointToJson(this);

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        timestamp,
        accuracy,
        altitude,
        speed,
      ];
}
