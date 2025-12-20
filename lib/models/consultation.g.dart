// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationImpl _$$ConsultationImplFromJson(Map<String, dynamic> json) =>
    _$ConsultationImpl(
      id: json[r'$id'] as String?,
      createdAt: json[r'$createdAt'] == null
          ? null
          : DateTime.parse(json[r'$createdAt'] as String),
      updatedAt: json[r'$updatedAt'] == null
          ? null
          : DateTime.parse(json[r'$updatedAt'] as String),
      patientId: json['patientId'] as String,
      volunteerId: json['volunteerId'] as String,
      department: json['department'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      chiefComplaint: json['chiefComplaint'] as String,
      examinationFindings: json['examinationFindings'] as String?,
      diagnosis: json['diagnosis'] as String?,
      prescription: json['prescription'] as String?,
      advice: json['advice'] as String?,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      referredTo: json['referredTo'] as String?,
    );

Map<String, dynamic> _$$ConsultationImplToJson(_$ConsultationImpl instance) =>
    <String, dynamic>{
      r'$id': instance.id,
      r'$createdAt': instance.createdAt?.toIso8601String(),
      r'$updatedAt': instance.updatedAt?.toIso8601String(),
      'patientId': instance.patientId,
      'volunteerId': instance.volunteerId,
      'department': instance.department,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'chiefComplaint': instance.chiefComplaint,
      'examinationFindings': instance.examinationFindings,
      'diagnosis': instance.diagnosis,
      'prescription': instance.prescription,
      'advice': instance.advice,
      'followUpRequired': instance.followUpRequired,
      'referredTo': instance.referredTo,
    };
