import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  final UserModel? currentUser;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    UserModel? currentUser,
    bool clearUser = false,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient, AuthService(apiClient));
});

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthViewModel extends Notifier<AuthState> {
  static const mockStudent = UserModel(
    id: 3,
    fullName: 'Aarav Patel',
    email: 'student@campus.edu',
    role: 'student',
    studentIdNumber: '24CE001',
    department: 'Computer Engineering',
    phone: '+91 98765 43210',
    isActive: true,
  );

  static const mockOrganizer = UserModel(
    id: 2,
    fullName: 'Dr. Priya Sharma',
    email: 'organizer@campus.edu',
    role: 'organizer',
    studentIdNumber: null,
    department: 'Information Technology',
    phone: '+91 98765 12345',
    isActive: true,
  );

  static const mockAdmin = UserModel(
    id: 1,
    fullName: 'System Administrator',
    email: 'admin@campus.edu',
    role: 'admin',
    studentIdNumber: null,
    department: 'Campus IT Administration',
    phone: '+91 98765 00000',
    isActive: true,
  );

  @override
  AuthState build() {
    Future.microtask(initialize);
    return const AuthState(isLoading: true);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.restoreSession();
      state = state.copyWith(
        currentUser: user,
        clearUser: user == null,
        isLoading: false,
        isInitialized: true,
      );
    } catch (_) {
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  void loginAsRole(String role) {
    UserModel user;
    if (role == 'admin') {
      user = mockAdmin;
    } else if (role == 'organizer') {
      user = mockOrganizer;
    } else {
      user = mockStudent;
    }
    state = state.copyWith(
      currentUser: user,
      isLoading: false,
      isInitialized: true,
      clearError: true,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
        isInitialized: true,
      );
      return true;
    } on ApiException catch (e) {
      // In UI sprint (backend not connected yet), fallback to mock user matching role
      return _fallbackMockLogin(email, error: e.message);
    } catch (_) {
      // Offline / backend not running during UI sprint
      return _fallbackMockLogin(email);
    }
  }

  bool _fallbackMockLogin(String email, {String? error}) {
    final lower = email.toLowerCase();
    UserModel user;
    if (lower.contains('admin')) {
      user = mockAdmin;
    } else if (lower.contains('organizer')) {
      user = mockOrganizer;
    } else {
      user = mockStudent;
    }
    state = state.copyWith(
      currentUser: user,
      isLoading: false,
      isInitialized: true,
      clearError: true,
    );
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? studentIdNumber,
    String? department,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        studentIdNumber: studentIdNumber,
        department: department,
      );
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
        isInitialized: true,
      );
      return true;
    } catch (_) {
      // Fallback for UI sprint preview
      final mock = UserModel(
        id: 99,
        fullName: fullName,
        email: email,
        role: 'student',
        studentIdNumber: studentIdNumber,
        department: department ?? 'Computer Engineering',
        isActive: true,
      );
      state = state.copyWith(
        currentUser: mock,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
      return true;
    }
  }

  void updateUser(UserModel user) {
    state = state.copyWith(currentUser: user);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore network errors on logout during UI sprint
    } finally {
      state = state.copyWith(clearUser: true, isLoading: false);
    }
  }
}
