import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'trip_plan_model.g.dart';

@HiveType(typeId: 9)
@JsonSerializable()
class TripPlanModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String destination;
  
  @HiveField(4)
  final DateTime startDate;
  
  @HiveField(5)
  final DateTime endDate;
  
  @HiveField(6)
  final String? description;
  
  @HiveField(7)
  final double? budget;
  
  @HiveField(8)
  final String currency;
  
  @HiveField(9)
  final TripPlanStatus status;
  
  @HiveField(10)
  final List<ItineraryItem> itinerary;
  
  @HiveField(11)
  final List<String> sharedWith;
  
  @HiveField(12)
  final List<String> tags;
  
  @HiveField(13)
  final String? coverImageUrl;
  
  @HiveField(14)
  final Map<String, dynamic> preferences;
  
  @HiveField(15)
  final DateTime createdAt;
  
  @HiveField(16)
  final DateTime updatedAt;

  const TripPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.description,
    this.budget,
    this.currency = 'USD',
    required this.status,
    this.itinerary = const [],
    this.sharedWith = const [],
    this.tags = const [],
    this.coverImageUrl,
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TripPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripPlanModelToJson(this);

  TripPlanModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    double? budget,
    String? currency,
    TripPlanStatus? status,
    List<ItineraryItem>? itinerary,
    List<String>? sharedWith,
    List<String>? tags,
    String? coverImageUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      itinerary: itinerary ?? this.itinerary,
      sharedWith: sharedWith ?? this.sharedWith,
      tags: tags ?? this.tags,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        destination,
        startDate,
        endDate,
        description,
        budget,
        currency,
        status,
        itinerary,
        sharedWith,
        tags,
        coverImageUrl,
        preferences,
        createdAt,
        updatedAt,
      ];
}

@HiveType(typeId: 10)
enum TripPlanStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 11)
@JsonSerializable()
class ItineraryItem extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final DateTime dateTime;
  
  @HiveField(3)
  final String? location;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final double? latitude;
  
  @HiveField(6)
  final double? longitude;
  
  @HiveField(7)
  final ItineraryItemType type;
  
  @HiveField(8)
  final double? estimatedCost;
  
  @HiveField(9)
  final String? currency;
  
  @HiveField(10)
  final int duration; // in minutes
  
  @HiveField(11)
  final List<String> notes;
  
  @HiveField(12)
  final List<String> imageUrls;
  
  @HiveField(13)
  final Map<String, dynamic> metadata;

  const ItineraryItem({
    required this.id,
    required this.title,
    required this.dateTime,
    this.location,
    this.description,
    this.latitude,
    this.longitude,
    required this.type,
    this.estimatedCost,
    this.currency = 'USD',
    this.duration = 60,
    this.notes = const [],
    this.imageUrls = const [],
    this.metadata = const {},
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryItemToJson(this);

  ItineraryItem copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? location,
    String? description,
    double? latitude,
    double? longitude,
    ItineraryItemType? type,
    double? estimatedCost,
    String? currency,
    int? duration,
    List<String>? notes,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currency: currency ?? this.currency,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        dateTime,
        location,
        description,
        latitude,
        longitude,
        type,
        estimatedCost,
        currency,
        duration,
        notes,
        imageUrls,
        metadata,
      ];
}

@HiveType(typeId: 12)
enum ItineraryItemType {
  @HiveField(0)
  accommodation,
  @HiveField(1)
  transportation,
  @HiveField(2)
  activity,
  @HiveField(3)
  restaurant,
  @HiveField(4)
  attraction,
  @HiveField(5)
  meeting,
  @HiveField(6)
  break_time,
  @HiveField(7)
  other,
}

@HiveType(typeId: 13)
@JsonSerializable()
class ShareInfo extends Equatable {
  @HiveField(0)
  final String shareId;
  
  @HiveField(1)
  final String tripPlanId;
  
  @HiveField(2)
  final List<String> sharedWith;
  
  @HiveField(3)
  final SharePermissions permissions;
  
  @HiveField(4)
  final DateTime sharedAt;

  const ShareInfo({
    required this.shareId,
    required this.tripPlanId,
    required this.sharedWith,
    required this.permissions,
    required this.sharedAt,
  });

  factory ShareInfo.fromJson(Map<String, dynamic> json) =>
      _$ShareInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ShareInfoToJson(this);

  @override
  List<Object?> get props => [
        shareId,
        tripPlanId,
        sharedWith,
        permissions,
        sharedAt,
      ];
}

@HiveType(typeId: 14)
enum SharePermissions {
  @HiveField(0)
  view,
  @HiveField(1)
  edit,
  @HiveField(2)
  admin,
}
