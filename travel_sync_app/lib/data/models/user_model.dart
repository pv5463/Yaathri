import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class UserModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String? fullName;
  
  @HiveField(3)
  final String? phoneNumber;
  
  @HiveField(4)
  final String? profileImageUrl;
  
  @HiveField(5)
  final List<String> travelPreferences;
  
  @HiveField(6)
  final bool consentGiven;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final bool isVerified;
  
  @HiveField(10)
  final Map<String, dynamic>? settings;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    this.travelPreferences = const [],
    required this.consentGiven,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.settings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? travelPreferences,
    bool? consentGiven,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      consentGiven: consentGiven ?? this.consentGiven,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        profileImageUrl,
        travelPreferences,
        consentGiven,
        createdAt,
        updatedAt,
        isVerified,
        settings,
      ];
}
