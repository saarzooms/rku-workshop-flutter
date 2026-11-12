import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel(this._repository);

  final AttendanceRepository _repository;

  AttendanceQrModel? _activeQr;
  AttendanceSummary? _summary;
  List<AttendeeReportItem> _attendees = [];
  bool _isLoading = false;
  String? _errorMessage;

  AttendanceQrModel? get activeQr => _activeQr;
  AttendanceSummary? get summary => _summary;
  List<AttendeeReportItem> get attendees => _attendees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> generateQr(int eventId, {int ttlMinutes = 15}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeQr =
          await _repository.generateQr(eventId, ttlMinutes: ttlMinutes);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to generate QR code.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<({bool ok, String message})> verifyQrToken(String qrToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      final msg = await _repository.verifyQr(qrToken);
      return (ok: true, message: msg);
    } on ApiException catch (e) {
      return (ok: false, message: e.message);
    } catch (_) {
      return (ok: false, message: 'Failed to verify QR code.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventReport(int eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getEventReport(eventId);
      _summary = result.summary;
      _attendees = result.attendees;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load attendance report.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
