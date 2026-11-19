import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../viewmodels/attendance_viewmodel.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState
    extends ConsumerState<AttendanceReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => mounted
        ? ref
            .read(attendanceViewModelProvider.notifier)
            .loadEventReport(widget.eventId)
        : null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceViewModelProvider);
    final notifier = ref.read(attendanceViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const LoadingStateView(message: 'Loading report...');
          }
          if (state.errorMessage != null) {
            return ErrorStateView(
              message: state.errorMessage!,
              onRetry: () => notifier.loadEventReport(widget.eventId),
            );
          }

          final summary = state.summary;
          if (summary == null) {
            return const EmptyStateView(
              icon: Icons.analytics_outlined,
              title: 'No Report Data',
              subtitle: 'No registrations found for this event yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => notifier.loadEventReport(widget.eventId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.eventTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(
                                label: 'Registered',
                                value: summary.totalRegistered.toString()),
                            _StatChip(
                                label: 'Present',
                                value: summary.totalPresent.toString()),
                            _StatChip(
                                label: 'Rate',
                                value: '${summary.attendanceRate}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Registered Students',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (state.attendees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No students registered yet.')),
                  )
                else
                  ...state.attendees.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isPresent
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          child: Icon(
                            item.isPresent ? Icons.check : Icons.schedule,
                            color: item.isPresent
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                          ),
                        ),
                        title: Text(item.fullName),
                        subtitle: Text(item.studentIdNumber ?? item.email),
                        trailing: Text(
                          item.isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: item.isPresent
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}
