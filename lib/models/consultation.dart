import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation.freezed.dart';
part 'consultation.g.dart';

@freezed
class Consultation with _$Consultation {
  const factory Consultation({
    @JsonKey(name: '\$id') String? id,
    @JsonKey(name: '\$createdAt') DateTime? createdAt,
    @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
    required String patientId,
    required String volunteerId,
    required String department,
    required DateTime startedAt,
    DateTime? completedAt,
    required String chiefComplaint,
    String? examinationFindings,
    String? diagnosis,
    String? prescription,
    String? advice,
    @Default(false) bool followUpRequired,
    String? referredTo,
  }) = _Consultation;

  const Consultation._();

  factory Consultation.fromJson(Map<String, dynamic> json) =>
      _$ConsultationFromJson(json);

  // Helper methods
  bool get isCompleted => completedAt != null;
  
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }
  
  String get formattedDuration {
    final dur = duration;
    if (dur == null) return 'In progress';
    
    final minutes = dur.inMinutes;
    if (minutes < 60) return '$minutes min';
    final hours = dur.inHours;
    final remainingMinutes = minutes % 60;
    return '$hours hr $remainingMinutes min';
  }
  
  // Template shortcuts for common prescriptions and advice
  static Map<String, String> get prescriptionTemplates => {
    'fever': 'Paracetamol 500mg SOS for fever',
    'cold': 'Cetirizine 10mg once daily for 5 days',
    'cough': 'Dextromethorphan syrup 10ml twice daily',
    'pain': 'Ibuprofen 400mg twice daily after food',
    'infection': 'Amoxicillin 500mg thrice daily for 7 days',
  };
  
  static Map<String, String> get adviceTemplates => {
    'rest': 'Take adequate rest for 2-3 days',
    'hydration': 'Drink plenty of fluids (8-10 glasses daily)',
    'diet': 'Maintain light, nutritious diet',
    'exercise': 'Regular light exercise as tolerated',
    'followup': 'Return for follow-up if symptoms persist',
  };
}