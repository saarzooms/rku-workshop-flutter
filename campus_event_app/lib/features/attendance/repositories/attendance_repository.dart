import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  AttendanceRepository(this._service);

  final AttendanceService _service;

  Future<AttendanceQrModel> generateQr(int eventId,
      {int ttlMinutes = 15}) async {
    final resp = await _service.generateQr(eventId, ttlMinutes: ttlMinutes);
    return AttendanceQrModel.fromJson(resp['data'] as Map<String, dynamic>);
  }

  Future<String> verifyQr(String qrToken) async {
    final resp = await _service.verifyQr(qrToken);
    final eventTitle = resp['data']?['event_title']?.toString() ?? 'Event';
    return 'Attendance marked for $eventTitle';
  }

  Future<({AttendanceSummary summary, List<AttendeeReportItem> attendees})>
      getEventReport(int eventId) async {
    final resp = await _service.fetchEventReport(eventId);
    final data = resp['data'] as Map<String, dynamic>;
    final summary =
        AttendanceSummary.fromJson(data['summary'] as Map<String, dynamic>);
    final attendees = ((data['attendees'] as List?) ?? [])
        .map((e) => AttendeeReportItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return (summary: summary, attendees: attendees);
  }
}
