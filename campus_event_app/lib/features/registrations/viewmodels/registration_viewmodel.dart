import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../models/registration_model.dart';
import '../repositories/registration_repository.dart';
import '../services/registration_service.dart';

class RegistrationState {
  const RegistrationState({
    this.registrations = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<RegistrationModel> registrations;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  RegistrationState copyWith({
    List<RegistrationModel>? registrations,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegistrationState(
      registrations: registrations ?? this.registrations,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepository(
    RegistrationService(ref.watch(apiClientProvider)),
  );
});

final registrationViewModelProvider =
    NotifierProvider<RegistrationViewModel, RegistrationState>(
  RegistrationViewModel.new,
);

class RegistrationViewModel extends Notifier<RegistrationState> {
  @override
  RegistrationState build() => const RegistrationState();

  RegistrationRepository get _repository =>
      ref.read(registrationRepositoryProvider);

  Future<void> loadMyRegistrations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getMyRegistrations();
      state = state.copyWith(registrations: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load your registrations.',
      );
    }
  }

  Future<String?> registerForEvent(int eventId) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.register(eventId);
      await loadMyRegistrations();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Registration failed. Please try again.';
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<String?> cancelRegistration(int eventId) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.cancel(eventId);
      await loadMyRegistrations();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not cancel registration.';
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
