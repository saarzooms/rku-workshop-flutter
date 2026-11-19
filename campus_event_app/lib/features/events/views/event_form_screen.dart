import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';
import '../viewmodels/event_viewmodel.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.existingEvent});

  final EventModel? existingEvent;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _venueController;
  late final TextEditingController _capacityController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  int? _categoryId;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _venueController = TextEditingController(text: e?.venue ?? '');
    _capacityController =
        TextEditingController(text: (e?.maxCapacity ?? 100).toString());

    final defaultStart = DateTime.now().add(const Duration(days: 1));
    final defaultEnd = defaultStart.add(const Duration(hours: 2));
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

    _startController = TextEditingController(
      text: e?.startTime ?? fmt.format(defaultStart),
    );
    _endController = TextEditingController(
      text: e?.endTime ?? fmt.format(defaultEnd),
    );
    _categoryId = e?.categoryId;

    Future.microtask(() {
      if (!mounted) return;
      if (ref.read(eventViewModelProvider).categories.isEmpty) {
        ref.read(eventViewModelProvider.notifier).loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(eventViewModelProvider);
    final catId = _categoryId ??
        (state.categories.isNotEmpty ? state.categories.first.id : 1);

    final ok = await ref.read(eventViewModelProvider.notifier).saveEvent(
      eventId: widget.existingEvent?.id,
      payload: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category_id': catId,
        'venue': _venueController.text.trim(),
        'start_time': _startController.text.trim(),
        'end_time': _endController.text.trim(),
        'max_capacity': int.parse(_capacityController.text.trim()),
      },
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully')),
      );
      context.pop();
    } else {
      final err = ref.read(eventViewModelProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventViewModelProvider);
    final isEditing = widget.existingEvent != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 14),
              if (state.categories.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _categoryId ?? state.categories.first.id,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: state.categories
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _categoryId = val),
                ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Venue required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Capacity'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid capacity';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _startController,
                decoration: const InputDecoration(
                    labelText: 'Start Time (YYYY-MM-DD HH:MM:SS)'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Start time required'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _endController,
                decoration: const InputDecoration(
                    labelText: 'End Time (YYYY-MM-DD HH:MM:SS)'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'End time required'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description required'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.isSubmitting ? null : _submit,
                child: Text(isEditing ? 'Update Event' : 'Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
