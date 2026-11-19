import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/event_card.dart';
import '../../events/viewmodels/event_viewmodel.dart';

class OrganizerDashboardTab extends ConsumerStatefulWidget {
  const OrganizerDashboardTab({super.key});

  @override
  ConsumerState<OrganizerDashboardTab> createState() =>
      _OrganizerDashboardTabState();
}

class _OrganizerDashboardTabState extends ConsumerState<OrganizerDashboardTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => mounted
        ? ref.read(eventViewModelProvider.notifier).loadEvents(mine: true)
        : null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventViewModelProvider);
    final totalReg =
        state.events.fold<int>(0, (sum, e) => sum + e.registeredCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(eventViewModelProvider.notifier).loadEvents(mine: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'My Events',
                    value: state.events.length.toString(),
                    icon: Icons.event_available,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Registrations',
                    value: totalReg.toString(),
                    icon: Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'My Published & Draft Events',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (state.isLoading && state.events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('You have not created any events yet.'),
                ),
              )
            else
              ...state.events.map(
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
