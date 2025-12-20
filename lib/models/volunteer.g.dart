// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volunteer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VolunteerImpl _$$VolunteerImplFromJson(Map<String, dynamic> json) =>
    _$VolunteerImpl(
      id: json[r'$id'] as String?,
      createdAt: json[r'$createdAt'] == null
          ? null
          : DateTime.parse(json[r'$createdAt'] as String),
      updatedAt: json[r'$updatedAt'] == null
          ? null
          : DateTime.parse(json[r'$updatedAt'] as String),
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'volunteer',
      department: json['department'] as String,
      isActive: json['isActive'] as bool? ?? true,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$VolunteerImplToJson(_$VolunteerImpl instance) =>
    <String, dynamic>{
      r'$id': instance.id,
      r'$createdAt': instance.createdAt?.toIso8601String(),
      r'$updatedAt': instance.updatedAt?.toIso8601String(),
      'fullName': instance.fullName,
      'phone': instance.phone,
      'role': instance.role,
      'department': instance.department,
      'isActive': instance.isActive,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
