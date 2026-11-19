import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../services/attendance_service.dart';

class AttendanceState {
  const AttendanceState({
    this.activeQr,
    this.summary,
    this.attendees = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final AttendanceQrModel? activeQr;
  final AttendanceSummary? summary;
  final List<AttendeeReportItem> attendees;
  final bool isLoading;
  final String? errorMessage;

  AttendanceState copyWith({
    AttendanceQrModel? activeQr,
    AttendanceSummary? summary,
    List<AttendeeReportItem>? attendees,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AttendanceState(
      activeQr: activeQr ?? this.activeQr,
      summary: summary ?? this.summary,
      attendees: attendees ?? this.attendees,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(AttendanceService(ref.watch(apiClientProvider)));
});

final attendanceViewModelProvider =
    NotifierProvider<AttendanceViewModel, AttendanceState>(
  AttendanceViewModel.new,
);

class AttendanceViewModel extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => const AttendanceState();

  AttendanceRepository get _repository =>
      ref.read(attendanceRepositoryProvider);

  Future<void> generateQr(int eventId, {int ttlMinutes = 15}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final qr =
          await _repository.generateQr(eventId, ttlMinutes: ttlMinutes);
      state = state.copyWith(activeQr: qr, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate QR code.',
      );
    }
  }

  Future<({bool ok, String message})> verifyQrToken(String qrToken) async {
    state = state.copyWith(isLoading: true);
    try {
      final msg = await _repository.verifyQr(qrToken);
      return (ok: true, message: msg);
    } on ApiException catch (e) {
      return (ok: false, message: e.message);
    } catch (_) {
      return (ok: false, message: 'Failed to verify QR code.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadEventReport(int eventId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getEventReport(eventId);
      state = state.copyWith(
        summary: result.summary,
        attendees: result.attendees,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load attendance report.',
      );
    }
  }
}
