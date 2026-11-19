import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class RegistrationService {
  RegistrationService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> registerForEvent(int eventId) {
    return _apiClient.post(ApiConstants.eventRegister(eventId));
  }

  Future<Map<String, dynamic>> cancelRegistration(int eventId) {
    return _apiClient.delete(ApiConstants.eventRegister(eventId));
  }

  Future<Map<String, dynamic>> fetchMyRegistrations() {
    return _apiClient.get(ApiConstants.myRegistrations);
  }
}
