import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class AttendanceService {
  AttendanceService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> generateQr(int eventId, {int ttlMinutes = 15}) {
    return _apiClient.post(
      ApiConstants.generateAttendanceQr(eventId),
      body: {'ttl_minutes': ttlMinutes},
    );
  }

  Future<Map<String, dynamic>> verifyQr(String qrToken) {
    return _apiClient.post(
      ApiConstants.verifyAttendance,
      body: {'qr_token': qrToken},
    );
  }

  Future<Map<String, dynamic>> fetchEventReport(int eventId) {
    return _apiClient.get(ApiConstants.eventAttendanceReport(eventId));
  }
}
