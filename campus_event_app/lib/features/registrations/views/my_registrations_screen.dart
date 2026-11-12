import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/state_views.dart';
import '../viewmodels/registration_viewmodel.dart';

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => mounted
          ? context.read<RegistrationViewModel>().loadMyRegistrations()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const LoadingStateView(message: 'Loading your events...');
          }
          if (vm.errorMessage != null) {
            return ErrorStateView(
              message: vm.errorMessage!,
              onRetry: vm.loadMyRegistrations,
            );
          }
          if (vm.registrations.isEmpty) {
            return const EmptyStateView(
              icon: Icons.event_busy_outlined,
              title: 'No Registrations Yet',
              subtitle: 'Explore campus events and register to see them here.',
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadMyRegistrations,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.registrations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reg = vm.registrations[index];
                final isCancelled = reg.registrationStatus == 'cancelled';

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () => context.push('/events/${reg.eventId}'),
                    title: Text(
                      reg.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(DateFormatter.formatShortDate(reg.startTime)),
                        Text(reg.venue),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                isCancelled ? 'Cancelled' : 'Registered',
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            if (reg.isAttended)
                              Chip(
                                label: const Text(
                                  'Attended',
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.green.shade100,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
