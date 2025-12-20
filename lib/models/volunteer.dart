import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'volunteer.freezed.dart';
part 'volunteer.g.dart';

@freezed
class Volunteer with _$Volunteer {
  const factory Volunteer({
    @JsonKey(name: '\$id') String? id,
    @JsonKey(name: '\$createdAt') DateTime? createdAt,
    @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
    //required String userId,
    required String fullName,
    required String phone,
    @Default('volunteer') String role,
    required String department,
    @Default(true) bool isActive,
    required DateTime joinedAt,
  }) = _Volunteer;

  const Volunteer._();

  factory Volunteer.fromJson(Map<String, dynamic> json) =>
      _$VolunteerFromJson(json);

  // Helper method to check if user is admin
  bool get isAdmin => role == 'admin';
  
  // Helper method to check if user has write permissions
  bool get canWrite => role == 'admin' || role == 'volunteer';
}

// Volunteer role enum
enum VolunteerRole {
  admin,
  volunteer,
  viewer;

  String toJson() => name;
  static VolunteerRole fromJson(String value) => values.byName(value);
}