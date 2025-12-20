import 'package:freezed_annotation/freezed_annotation.dart';

part 'vital_signs.freezed.dart';
part 'vital_signs.g.dart';

@freezed
class VitalSigns with _$VitalSigns {
  const factory VitalSigns({
    @JsonKey(name: '\$id') String? id,
    @JsonKey(name: '\$createdAt') DateTime? createdAt,
    @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
    required String patientId,
    required String recordedBy,
    required DateTime recordedAt,
    String? temperature,
    String? bloodPressure,
    int? pulse,
    int? respiratoryRate,
    String? weight,
    String? height,
    String? notes,
  }) = _VitalSigns;

  const VitalSigns._();

  factory VitalSigns.fromJson(Map<String, dynamic> json) =>
      _$VitalSignsFromJson(json);

  // Helper method to get BMI
  double? get bmi {
    if (weight == null || height == null) return null;
    
    final weightKg = _parseMeasurement(weight!);
    final heightM = _parseMeasurement(height!)! / 100; // Convert to meters
    
    if (weightKg == null || heightM == null || heightM == 0) return null;
    
    return weightKg / (heightM * heightM);
  }

  // Helper method to parse measurement strings like "65 kg" or "170 cm"
  double? _parseMeasurement(String measurement) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(measurement);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  // Get vital signs summary
  String get summary {
    final parts = <String>[];
    if (temperature != null) parts.add('Temp: $temperature');
    if (bloodPressure != null) parts.add('BP: $bloodPressure');
    if (pulse != null) parts.add('Pulse: $pulse');
    if (respiratoryRate != null) parts.add('RR: $respiratoryRate');
    return parts.join(' | ');
  }
}