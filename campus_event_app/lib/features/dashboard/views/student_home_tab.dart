import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/event_card.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../events/viewmodels/event_viewmodel.dart';
import '../../registrations/viewmodels/registration_viewmodel.dart';

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key, required this.onSwitchTab});

  final void Function(int index) onSwitchTab;

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EventViewModel>().loadEvents();
      context.read<RegistrationViewModel>().loadMyRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final eventVm = context.watch<EventViewModel>();
    final regVm = context.watch<RegistrationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.fullName.split(' ').first ?? 'Student'}'),
        actions: [
          IconButton(
            tooltip: 'Scan Attendance QR',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/attendance/scan'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            eventVm.loadEvents(),
            regVm.loadMyRegistrations(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campus Event Pass',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${regVm.registrations.where((r) => r.registrationStatus == 'registered').length} Active Registrations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/attendance/scan'),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Event Attendance QR'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => widget.onSwitchTab(1),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (eventVm.isLoading && eventVm.events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (eventVm.events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No upcoming events right now.')),
              )
            else
              ...eventVm.events.take(5).map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EventCard(
                        event: event,
                        onTap: () => context.push('/events/${event.id}'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
