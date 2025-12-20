// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_signs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VitalSignsImpl _$$VitalSignsImplFromJson(Map<String, dynamic> json) =>
    _$VitalSignsImpl(
      id: json[r'$id'] as String?,
      createdAt: json[r'$createdAt'] == null
          ? null
          : DateTime.parse(json[r'$createdAt'] as String),
      updatedAt: json[r'$updatedAt'] == null
          ? null
          : DateTime.parse(json[r'$updatedAt'] as String),
      patientId: json['patientId'] as String,
      recordedBy: json['recordedBy'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      temperature: json['temperature'] as String?,
      bloodPressure: json['bloodPressure'] as String?,
      pulse: (json['pulse'] as num?)?.toInt(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
      weight: json['weight'] as String?,
      height: json['height'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$VitalSignsImplToJson(_$VitalSignsImpl instance) =>
    <String, dynamic>{
      r'$id': instance.id,
      r'$createdAt': instance.createdAt?.toIso8601String(),
      r'$updatedAt': instance.updatedAt?.toIso8601String(),
      'patientId': instance.patientId,
      'recordedBy': instance.recordedBy,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'temperature': instance.temperature,
      'bloodPressure': instance.bloodPressure,
      'pulse': instance.pulse,
      'respiratoryRate': instance.respiratoryRate,
      'weight': instance.weight,
      'height': instance.height,
      'notes': instance.notes,
    };
