import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._authService);

  final ApiClient _apiClient;
  final AuthService _authService;

  Future<UserModel> login(String email, String password) async {
    final response = await _authService.login(email, password);
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await _apiClient.saveToken(token);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? studentIdNumber,
    String? department,
  }) async {
    final response = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      studentIdNumber: studentIdNumber,
      department: department,
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await _apiClient.saveToken(token);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> restoreSession() async {
    final token = await _apiClient.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final response = await _authService.getProfile();
      final data = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      await _apiClient.clearToken();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      await _apiClient.clearToken();
    }
  }
}
