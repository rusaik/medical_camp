import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    @JsonKey(name: '\$id') String? id,
    @JsonKey(name: '\$createdAt') DateTime? createdAt,
    @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
    required String campId,
    required String registrationNumber,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    String? phone,
    required String address,
    required String registeredBy,
    required DateTime registeredAt,
    @Default('waiting') String status,
    @Default('routine') String priority,
  }) = _Patient;

  const Patient._();

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  // Helper methods
  String get fullName => '$firstName $lastName';
  
  bool get isWaiting => status == 'waiting';
  bool get isInConsultation => status == 'in_consultation';
  bool get isCompleted => status == 'completed';
  bool get isReferred => status == 'referred';
  
  bool get isUrgent => priority == 'urgent';
  bool get isEmergency => priority == 'emergency';
  bool get isRoutine => priority == 'routine';
  
  // Calculate wait time
  Duration get waitTime => DateTime.now().difference(registeredAt);
  String get formattedWaitTime {
    final minutes = waitTime.inMinutes;
    if (minutes < 60) return '$minutes min';
    final hours = waitTime.inHours;
    if (hours < 24) return '$hours hr';
    return '${waitTime.inDays} days';
  }
}

// Patient status enum
enum PatientStatus {
  waiting,
  inConsultation,
  completed,
  referred;

  String toJson() => name;
  static PatientStatus fromJson(String value) => values.byName(value);
}

// Patient priority enum
enum PatientPriority {
  routine,
  urgent,
  emergency;

  String toJson() => name;
  static PatientPriority fromJson(String value) => values.byName(value);
}