import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/views/attendance_report_screen.dart';
import '../../features/attendance/views/qr_generate_screen.dart';
import '../../features/attendance/views/qr_scan_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/dashboard/views/home_shell.dart';
import '../../features/events/models/event_model.dart';
import '../../features/events/views/event_detail_screen.dart';
import '../../features/events/views/event_form_screen.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(authViewModelProvider, (_, _) {
    refreshNotifier.notify();
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authViewModelProvider);
      if (!authState.isInitialized) return null;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (authState.isAuthenticated && isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const HomeShell(),
      ),
      GoRoute(
        path: '/events/create',
        builder: (_, _) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder: (_, state) {
          final existing = state.extra as EventModel?;
          return EventFormScreen(existingEvent: existing);
        },
      ),
      GoRoute(
        path: '/attendance/scan',
        builder: (_, _) => const QrScanScreen(),
      ),
      GoRoute(
        path: '/attendance/qr/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          final event = state.extra as EventModel?;
          return QrGenerateScreen(eventId: id, eventTitle: event?.title);
        },
      ),
      GoRoute(
        path: '/attendance/report/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AttendanceReportScreen(eventId: id);
        },
      ),
    ],
  );
});
