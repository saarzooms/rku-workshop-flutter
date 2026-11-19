import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/models/user_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).currentUser;
    _nameController.text = user?.fullName ?? '';
    _deptController.text = user?.department ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiClientProvider);
      final resp = await api.put(
        ApiConstants.profile,
        body: {
          'full_name': _nameController.text.trim(),
          'department': _deptController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );
      final updated =
          UserModel.fromJson(resp['data']['user'] as Map<String, dynamic>);
      if (!mounted) return;
      ref.read(authViewModelProvider.notifier).updateUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (_) {
      // Local fallback for UI preview
      final cur = ref.read(authViewModelProvider).currentUser;
      if (cur != null) {
        final local = cur.copyWith(
          fullName: _nameController.text.trim(),
          department: _deptController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        ref.read(authViewModelProvider.notifier).updateUser(local);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated (local preview)')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(user.email,
                              style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(user.role.toUpperCase(),
                                style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _deptController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'SWITCH ROLE PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Student'),
                          selected: user.isStudent,
                          onSelected: (_) {
                            ref
                                .read(authViewModelProvider.notifier)
                                .loginAsRole('student');
                            context.go('/home');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Organizer'),
                          selected: user.isOrganizer,
                          onSelected: (_) {
                            ref
                                .read(authViewModelProvider.notifier)
                                .loginAsRole('organizer');
                            context.go('/home');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Admin'),
                          selected: user.isAdmin,
                          onSelected: (_) {
                            ref
                                .read(authViewModelProvider.notifier)
                                .loginAsRole('admin');
                            context.go('/home');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authViewModelProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
