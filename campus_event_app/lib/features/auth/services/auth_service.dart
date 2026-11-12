import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login(String email, String password) {
    return _apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? studentIdNumber,
    String? department,
  }) {
    return _apiClient.post(
      ApiConstants.register,
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'student_id_number': studentIdNumber,
        'department': department,
      },
    );
  }

  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }

  Future<Map<String, dynamic>> getProfile() {
    return _apiClient.get(ApiConstants.profile);
  }
}
