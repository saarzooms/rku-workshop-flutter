import '../models/registration_model.dart';
import '../services/registration_service.dart';

class RegistrationRepository {
  RegistrationRepository(this._service);

  final RegistrationService _service;

  Future<void> register(int eventId) async {
    await _service.registerForEvent(eventId);
  }

  Future<void> cancel(int eventId) async {
    await _service.cancelRegistration(eventId);
  }

  Future<List<RegistrationModel>> getMyRegistrations() async {
    final resp = await _service.fetchMyRegistrations();
    final list = (resp['data']?['registrations'] as List?) ?? [];
    return list
        .map((e) => RegistrationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
