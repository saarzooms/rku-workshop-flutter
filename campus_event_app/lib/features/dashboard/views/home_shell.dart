import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../events/views/event_list_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../registrations/views/my_registrations_screen.dart';
import 'admin_dashboard_tab.dart';
import 'organizer_dashboard_tab.dart';
import 'student_home_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    late final List<Widget> pages;
    late final List<NavigationDestination> destinations;

    if (user.isOrganizer) {
      pages = const [
        OrganizerDashboardTab(),
        EventListScreen(mineOnly: true),
        EventListScreen(),
        ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
            icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined), label: 'Manage'),
        NavigationDestination(
            icon: Icon(Icons.explore_outlined), label: 'Explore'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ];
    } else if (user.isAdmin) {
      pages = const [
        AdminDashboardTab(),
        EventListScreen(),
        ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
        NavigationDestination(
            icon: Icon(Icons.event_outlined), label: 'Events'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ];
    } else {
      pages = [
        StudentHomeTab(
            onSwitchTab: (i) => setState(() => _selectedIndex = i)),
        const EventListScreen(),
        const MyRegistrationsScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.explore_outlined), label: 'Explore'),
        NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined), label: 'My Events'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ];
    }

    final safeIndex = _selectedIndex >= pages.length ? 0 : _selectedIndex;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: destinations,
      ),
    );
  }
}
