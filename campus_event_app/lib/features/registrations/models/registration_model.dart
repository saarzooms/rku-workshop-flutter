class RegistrationModel {
  const RegistrationModel({
    required this.registrationId,
    required this.eventId,
    required this.title,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.registrationStatus,
    required this.eventStatus,
    required this.categoryName,
    this.attendanceMarkedAt,
  });

  final int registrationId;
  final int eventId;
  final String title;
  final String venue;
  final String startTime;
  final String endTime;
  final String registrationStatus;
  final String eventStatus;
  final String categoryName;
  final String? attendanceMarkedAt;

  bool get isAttended =>
      attendanceMarkedAt != null && attendanceMarkedAt!.isNotEmpty;

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      registrationId: int.parse(json['registration_id'].toString()),
      eventId: int.parse(json['event_id'].toString()),
      title: (json['title'] ?? '').toString(),
      venue: (json['venue'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      registrationStatus: (json['registration_status'] ?? 'registered').toString(),
      eventStatus: (json['event_status'] ?? 'published').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      attendanceMarkedAt: json['attendance_marked_at']?.toString(),
    );
  }
}
