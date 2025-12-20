// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) =>
    _$PatientImpl(
      id: json[r'$id'] as String?,
      createdAt: json[r'$createdAt'] == null
          ? null
          : DateTime.parse(json[r'$createdAt'] as String),
      updatedAt: json[r'$updatedAt'] == null
          ? null
          : DateTime.parse(json[r'$updatedAt'] as String),
      campId: json['campId'] as String,
      registrationNumber: json['registrationNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String,
      registeredBy: json['registeredBy'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      status: json['status'] as String? ?? 'waiting',
      priority: json['priority'] as String? ?? 'routine',
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      r'$id': instance.id,
      r'$createdAt': instance.createdAt?.toIso8601String(),
      r'$updatedAt': instance.updatedAt?.toIso8601String(),
      'campId': instance.campId,
      'registrationNumber': instance.registrationNumber,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'age': instance.age,
      'gender': instance.gender,
      'phone': instance.phone,
      'address': instance.address,
      'registeredBy': instance.registeredBy,
      'registeredAt': instance.registeredAt.toIso8601String(),
      'status': instance.status,
      'priority': instance.priority,
    };
