import 'package:freezed_annotation/freezed_annotation.dart';

part 'camp.freezed.dart';
part 'camp.g.dart';

@freezed
class Camp with _$Camp {
  const factory Camp({
    @JsonKey(name: '\$id') String? id,
    @JsonKey(name: '\$createdAt') DateTime? createdAt,
    @JsonKey(name: '\$updatedAt') DateTime? updatedAt,
    required String name,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    @Default('planned') String status,
    required String createdBy,
  }) = _Camp;

  const Camp._();

  factory Camp.fromJson(Map<String, dynamic> json) =>
      _$CampFromJson(json);

  // Helper methods
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPlanned => status == 'planned';
  
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  // Get departments as string
  String get departmentsString => departments.join(', ');
  
  // Get duration in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;
  
  // Common departments for medical camps
  static List<String> get commonDepartments => [
    'General Medicine',
    'Pediatrics',
    'Gynecology',
    'Dental',
    'Orthopedics',
    'Ophthalmology',
    'ENT',
    'Dermatology',
    'Psychiatry',
    'Nutrition',
  ];
}

// Camp status enum
enum CampStatus {
  planned,
  active,
  completed;

  String toJson() => name;
  static CampStatus fromJson(String value) => values.byName(value);
}