import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../models/registration_model.dart';
import '../repositories/registration_repository.dart';

class RegistrationViewModel extends ChangeNotifier {
  RegistrationViewModel(this._repository);

  final RegistrationRepository _repository;

  List<RegistrationModel> _registrations = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<RegistrationModel> get registrations => _registrations;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyRegistrations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _registrations = await _repository.getMyRegistrations();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load your registrations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerForEvent(int eventId) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.register(eventId);
      await loadMyRegistrations();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Registration failed. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String?> cancelRegistration(int eventId) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.cancel(eventId);
      await loadMyRegistrations();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not cancel registration.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
