import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/state_views.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp =
          await context.read<ApiClient>().get(ApiConstants.adminStats);
      setState(() {
        _stats = resp['data']?['stats'] as Map<String, dynamic>?;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Overview')),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const LoadingStateView(message: 'Loading campus stats...');
          }
          if (_error != null) {
            return ErrorStateView(message: _error!, onRetry: _loadStats);
          }
          final s = _stats ?? {};
          return RefreshIndicator(
            onRefresh: _loadStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatTile('Total Users', s['total_users']?.toString() ?? '0',
                    Icons.group),
                _StatTile(
                    'Total Students',
                    s['total_students']?.toString() ?? '0',
                    Icons.school),
                _StatTile(
                    'Total Organizers',
                    s['total_organizers']?.toString() ?? '0',
                    Icons.badge),
                _StatTile('Published Events',
                    s['published_events']?.toString() ?? '0', Icons.event),
                _StatTile(
                    'Total Registrations',
                    s['total_registrations']?.toString() ?? '0',
                    Icons.how_to_reg),
                _StatTile(
                    'Total Attendance Recorded',
                    s['total_attendance']?.toString() ?? '0',
                    Icons.qr_code_2),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
