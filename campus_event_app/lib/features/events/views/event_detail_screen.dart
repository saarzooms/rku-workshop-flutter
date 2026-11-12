import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../registrations/viewmodels/registration_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => mounted
        ? context.read<EventViewModel>().loadEventDetail(widget.eventId)
        : null);
  }

  Future<void> _handleRegister() async {
    final regVm = context.read<RegistrationViewModel>();
    final eventVm = context.read<EventViewModel>();
    final err = await regVm.registerForEvent(widget.eventId);

    if (!mounted) return;
    if (err == null) {
      await eventVm.loadEventDetail(widget.eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered for event!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleCancelRegistration() async {
    final regVm = context.read<RegistrationViewModel>();
    final eventVm = context.read<EventViewModel>();
    final err = await regVm.cancelRegistration(widget.eventId);

    if (!mounted) return;
    if (err == null) {
      await eventVm.loadEventDetail(widget.eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration cancelled')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventVm = context.watch<EventViewModel>();
    final regVm = context.watch<RegistrationViewModel>();
    final user = context.watch<AuthViewModel>().currentUser;
    final event = eventVm.selectedEvent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (event != null &&
              user != null &&
              (user.isAdmin || user.id == event.organizerId))
            IconButton(
              tooltip: 'Edit Event',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/events/${event.id}/edit', extra: event),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (eventVm.isLoading && event == null) {
            return const LoadingStateView(message: 'Loading event...');
          }
          if (eventVm.errorMessage != null && event == null) {
            return ErrorStateView(
              message: eventVm.errorMessage!,
              onRetry: () => eventVm.loadEventDetail(widget.eventId),
            );
          }
          if (event == null) {
            return const EmptyStateView(
              icon: Icons.event_busy,
              title: 'Event Not Found',
              subtitle: 'This event may have been removed.',
            );
          }

          final isOwnerOrAdmin = user != null &&
              (user.isAdmin || user.id == event.organizerId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(label: Text(event.categoryName ?? 'General')),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          label: 'Starts',
                          value: DateFormatter.formatDateTime(event.startTime),
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.event_available_outlined,
                          label: 'Ends',
                          value: DateFormatter.formatDateTime(event.endTime),
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Venue',
                          value: event.venue,
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.people_outline,
                          label: 'Capacity',
                          value:
                              '${event.registeredCount} / ${event.maxCapacity} registered',
                        ),
                        if (event.organizerName != null) ...[
                          const Divider(height: 20),
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Organizer',
                            value: event.organizerName!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'About this event',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                if (user != null && user.isStudent) ...[
                  if (event.isRegistered)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.push('/attendance/scan'),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Attendance QR'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: regVm.isSubmitting
                              ? null
                              : _handleCancelRegistration,
                          child: const Text('Cancel Registration'),
                        ),
                      ],
                    )
                  else
                    FilledButton(
                      onPressed: (regVm.isSubmitting ||
                              event.isFull ||
                              event.status != 'published')
                          ? null
                          : _handleRegister,
                      child: Text(
                        event.isFull
                            ? 'Event Full'
                            : event.status != 'published'
                                ? 'Registration Closed'
                                : 'Register Now',
                      ),
                    ),
                ],
                if (isOwnerOrAdmin) ...[
                  FilledButton.icon(
                    onPressed: () =>
                        context.push('/attendance/qr/${event.id}', extra: event),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Generate Attendance QR'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                        '/attendance/report/${event.id}',
                        extra: event),
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('View Attendance Report'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
