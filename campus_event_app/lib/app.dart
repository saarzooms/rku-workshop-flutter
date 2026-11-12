import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/attendance/repositories/attendance_repository.dart';
import 'features/attendance/services/attendance_service.dart';
import 'features/attendance/viewmodels/attendance_viewmodel.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/events/repositories/event_repository.dart';
import 'features/events/services/event_service.dart';
import 'features/events/viewmodels/event_viewmodel.dart';
import 'features/notifications/services/fcm_service.dart';
import 'features/registrations/repositories/registration_repository.dart';
import 'features/registrations/services/registration_service.dart';
import 'features/registrations/viewmodels/registration_viewmodel.dart';

class CampusEventApp extends StatefulWidget {
  const CampusEventApp({super.key});

  @override
  State<CampusEventApp> createState() => _CampusEventAppState();
}

class _CampusEventAppState extends State<CampusEventApp> {
  late final ApiClient _apiClient;
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authViewModel = AuthViewModel(
      AuthRepository(_apiClient, AuthService(_apiClient)),
    )..initialize();
    _router = buildAppRouter(_authViewModel);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        Provider<FcmNotificationService>(
          create: (_) => FcmNotificationService(_apiClient),
        ),
        ChangeNotifierProvider<AuthViewModel>.value(value: _authViewModel),
        ChangeNotifierProvider<EventViewModel>(
          create: (_) => EventViewModel(
            EventRepository(EventService(_apiClient)),
          ),
        ),
        ChangeNotifierProvider<RegistrationViewModel>(
          create: (_) => RegistrationViewModel(
            RegistrationRepository(RegistrationService(_apiClient)),
          ),
        ),
        ChangeNotifierProvider<AttendanceViewModel>(
          create: (_) => AttendanceViewModel(
            AttendanceRepository(AttendanceService(_apiClient)),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Campus Event & Attendance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
