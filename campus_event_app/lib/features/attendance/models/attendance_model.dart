class AttendanceQrModel {
  const AttendanceQrModel({
    required this.eventId,
    required this.qrToken,
    required this.expiresAt,
    required this.ttlMinutes,
  });

  final int eventId;
  final String qrToken;
  final String expiresAt;
  final int ttlMinutes;

  factory AttendanceQrModel.fromJson(Map<String, dynamic> json) {
    return AttendanceQrModel(
      eventId: int.parse(json['event_id'].toString()),
      qrToken: (json['qr_token'] ?? '').toString(),
      expiresAt: (json['expires_at'] ?? '').toString(),
      ttlMinutes: int.tryParse(json['ttl_minutes']?.toString() ?? '15') ?? 15,
    );
  }
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.eventId,
    required this.eventTitle,
    required this.totalRegistered,
    required this.totalPresent,
    required this.attendanceRate,
  });

  final int eventId;
  final String eventTitle;
  final int totalRegistered;
  final int totalPresent;
  final double attendanceRate;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      eventId: int.parse(json['event_id'].toString()),
      eventTitle: (json['event_title'] ?? '').toString(),
      totalRegistered:
          int.tryParse(json['total_registered']?.toString() ?? '0') ?? 0,
      totalPresent: int.tryParse(json['total_present']?.toString() ?? '0') ?? 0,
      attendanceRate:
          double.tryParse(json['attendance_rate']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class AttendeeReportItem {
  const AttendeeReportItem({
    required this.userId,
    required this.fullName,
    required this.email,
    this.studentIdNumber,
    this.attendanceStatus,
    this.markedAt,
  });

  final int userId;
  final String fullName;
  final String email;
  final String? studentIdNumber;
  final String? attendanceStatus;
  final String? markedAt;

  bool get isPresent => attendanceStatus != null;

  factory AttendeeReportItem.fromJson(Map<String, dynamic> json) {
    return AttendeeReportItem(
      userId: int.parse(json['user_id'].toString()),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      studentIdNumber: json['student_id_number']?.toString(),
      attendanceStatus: json['attendance_status']?.toString(),
      markedAt: json['marked_at']?.toString(),
    );
  }
}
