// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Consultation _$ConsultationFromJson(Map<String, dynamic> json) {
  return _Consultation.fromJson(json);
}

/// @nodoc
mixin _$Consultation {
  @JsonKey(name: '\$id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: '\$createdAt')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: '\$updatedAt')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get volunteerId => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String get chiefComplaint => throw _privateConstructorUsedError;
  String? get examinationFindings => throw _privateConstructorUsedError;
  String? get diagnosis => throw _privateConstructorUsedError;
  String? get prescription => throw _privateConstructorUsedError;
  String? get advice => throw _privateConstructorUsedError;
  bool get followUpRequired => throw _privateConstructorUsedError;
  String? get referredTo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsultationCopyWith<Consultation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationCopyWith<$Res> {
  factory $ConsultationCopyWith(
          Consultation value, $Res Function(Consultation) then) =
      _$ConsultationCopyWithImpl<$Res, Consultation>;
  @useResult
  $Res call(
      {@JsonKey(name: '\$id') String? id,
      @JsonKey(name: '\$createdAt') DateTime? createdAt,
      @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
      String patientId,
      String volunteerId,
      String department,
      DateTime startedAt,
      DateTime? completedAt,
      String chiefComplaint,
      String? examinationFindings,
      String? diagnosis,
      String? prescription,
      String? advice,
      bool followUpRequired,
      String? referredTo});
}

/// @nodoc
class _$ConsultationCopyWithImpl<$Res, $Val extends Consultation>
    implements $ConsultationCopyWith<$Res> {
  _$ConsultationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? patientId = null,
    Object? volunteerId = null,
    Object? department = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? chiefComplaint = null,
    Object? examinationFindings = freezed,
    Object? diagnosis = freezed,
    Object? prescription = freezed,
    Object? advice = freezed,
    Object? followUpRequired = null,
    Object? referredTo = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      volunteerId: null == volunteerId
          ? _value.volunteerId
          : volunteerId // ignore: cast_nullable_to_non_nullable
              as String,
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      chiefComplaint: null == chiefComplaint
          ? _value.chiefComplaint
          : chiefComplaint // ignore: cast_nullable_to_non_nullable
              as String,
      examinationFindings: freezed == examinationFindings
          ? _value.examinationFindings
          : examinationFindings // ignore: cast_nullable_to_non_nullable
              as String?,
      diagnosis: freezed == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as String?,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
      followUpRequired: null == followUpRequired
          ? _value.followUpRequired
          : followUpRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      referredTo: freezed == referredTo
          ? _value.referredTo
          : referredTo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsultationImplCopyWith<$Res>
    implements $ConsultationCopyWith<$Res> {
  factory _$$ConsultationImplCopyWith(
          _$ConsultationImpl value, $Res Function(_$ConsultationImpl) then) =
      __$$ConsultationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '\$id') String? id,
      @JsonKey(name: '\$createdAt') DateTime? createdAt,
      @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
      String patientId,
      String volunteerId,
      String department,
      DateTime startedAt,
      DateTime? completedAt,
      String chiefComplaint,
      String? examinationFindings,
      String? diagnosis,
      String? prescription,
      String? advice,
      bool followUpRequired,
      String? referredTo});
}

/// @nodoc
class __$$ConsultationImplCopyWithImpl<$Res>
    extends _$ConsultationCopyWithImpl<$Res, _$ConsultationImpl>
    implements _$$ConsultationImplCopyWith<$Res> {
  __$$ConsultationImplCopyWithImpl(
      _$ConsultationImpl _value, $Res Function(_$ConsultationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? patientId = null,
    Object? volunteerId = null,
    Object? department = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? chiefComplaint = null,
    Object? examinationFindings = freezed,
    Object? diagnosis = freezed,
    Object? prescription = freezed,
    Object? advice = freezed,
    Object? followUpRequired = null,
    Object? referredTo = freezed,
  }) {
    return _then(_$ConsultationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      volunteerId: null == volunteerId
          ? _value.volunteerId
          : volunteerId // ignore: cast_nullable_to_non_nullable
              as String,
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      chiefComplaint: null == chiefComplaint
          ? _value.chiefComplaint
          : chiefComplaint // ignore: cast_nullable_to_non_nullable
              as String,
      examinationFindings: freezed == examinationFindings
          ? _value.examinationFindings
          : examinationFindings // ignore: cast_nullable_to_non_nullable
              as String?,
      diagnosis: freezed == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as String?,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
      followUpRequired: null == followUpRequired
          ? _value.followUpRequired
          : followUpRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      referredTo: freezed == referredTo
          ? _value.referredTo
          : referredTo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationImpl extends _Consultation {
  const _$ConsultationImpl(
      {@JsonKey(name: '\$id') this.id,
      @JsonKey(name: '\$createdAt') this.createdAt,
      @JsonKey(name: '\$updatedAt') this.updatedAt,
      required this.patientId,
      required this.volunteerId,
      required this.department,
      required this.startedAt,
      this.completedAt,
      required this.chiefComplaint,
      this.examinationFindings,
      this.diagnosis,
      this.prescription,
      this.advice,
      this.followUpRequired = false,
      this.referredTo})
      : super._();

  factory _$ConsultationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationImplFromJson(json);

  @override
  @JsonKey(name: '\$id')
  final String? id;
  @override
  @JsonKey(name: '\$createdAt')
  final DateTime? createdAt;
  @override
  @JsonKey(name: '\$updatedAt')
  final DateTime? updatedAt;
  @override
  final String patientId;
  @override
  final String volunteerId;
  @override
  final String department;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String chiefComplaint;
  @override
  final String? examinationFindings;
  @override
  final String? diagnosis;
  @override
  final String? prescription;
  @override
  final String? advice;
  @override
  @JsonKey()
  final bool followUpRequired;
  @override
  final String? referredTo;

  @override
  String toString() {
    return 'Consultation(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, patientId: $patientId, volunteerId: $volunteerId, department: $department, startedAt: $startedAt, completedAt: $completedAt, chiefComplaint: $chiefComplaint, examinationFindings: $examinationFindings, diagnosis: $diagnosis, prescription: $prescription, advice: $advice, followUpRequired: $followUpRequired, referredTo: $referredTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.volunteerId, volunteerId) ||
                other.volunteerId == volunteerId) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.chiefComplaint, chiefComplaint) ||
                other.chiefComplaint == chiefComplaint) &&
            (identical(other.examinationFindings, examinationFindings) ||
                other.examinationFindings == examinationFindings) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription) &&
            (identical(other.advice, advice) || other.advice == advice) &&
            (identical(other.followUpRequired, followUpRequired) ||
                other.followUpRequired == followUpRequired) &&
            (identical(other.referredTo, referredTo) ||
                other.referredTo == referredTo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      patientId,
      volunteerId,
      department,
      startedAt,
      completedAt,
      chiefComplaint,
      examinationFindings,
      diagnosis,
      prescription,
      advice,
      followUpRequired,
      referredTo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      __$$ConsultationImplCopyWithImpl<_$ConsultationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationImplToJson(
      this,
    );
  }
}

abstract class _Consultation extends Consultation {
  const factory _Consultation(
      {@JsonKey(name: '\$id') final String? id,
      @JsonKey(name: '\$createdAt') final DateTime? createdAt,
      @JsonKey(name: '\$updatedAt') final DateTime? updatedAt,
      required final String patientId,
      required final String volunteerId,
      required final String department,
      required final DateTime startedAt,
      final DateTime? completedAt,
      required final String chiefComplaint,
      final String? examinationFindings,
      final String? diagnosis,
      final String? prescription,
      final String? advice,
      final bool followUpRequired,
      final String? referredTo}) = _$ConsultationImpl;
  const _Consultation._() : super._();

  factory _Consultation.fromJson(Map<String, dynamic> json) =
      _$ConsultationImpl.fromJson;

  @override
  @JsonKey(name: '\$id')
  String? get id;
  @override
  @JsonKey(name: '\$createdAt')
  DateTime? get createdAt;
  @override
  @JsonKey(name: '\$updatedAt')
  DateTime? get updatedAt;
  @override
  String get patientId;
  @override
  String get volunteerId;
  @override
  String get department;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String get chiefComplaint;
  @override
  String? get examinationFindings;
  @override
  String? get diagnosis;
  @override
  String? get prescription;
  @override
  String? get advice;
  @override
  bool get followUpRequired;
  @override
  String? get referredTo;
  @override
  @JsonKey(ignore: true)
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
