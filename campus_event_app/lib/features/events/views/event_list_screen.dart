import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/event_card.dart';
import '../../../core/widgets/state_views.dart';
import '../viewmodels/event_viewmodel.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key, this.mineOnly = false});

  final bool mineOnly;

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(eventViewModelProvider.notifier);
      notifier.loadCategories();
      notifier.loadEvents(mine: widget.mineOnly);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventViewModelProvider);
    final notifier = ref.read(eventViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mineOnly ? 'Manage My Events' : 'Explore Events'),
      ),
      floatingActionButton: widget.mineOnly
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/events/create'),
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events, venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('', mine: widget.mineOnly);
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) =>
                  notifier.setSearchQuery(value, mine: widget.mineOnly),
            ),
          ),
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: state.selectedCategoryId == null,
                      onSelected: (_) =>
                          notifier.setCategoryFilter(null, mine: widget.mineOnly),
                    ),
                  ),
                  ...state.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: state.selectedCategoryId == cat.id,
                        onSelected: (_) => notifier.setCategoryFilter(
                          cat.id,
                          mine: widget.mineOnly,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const LoadingStateView(message: 'Loading events...');
                }
                if (state.errorMessage != null) {
                  return ErrorStateView(
                    message: state.errorMessage!,
                    onRetry: () => notifier.loadEvents(mine: widget.mineOnly),
                  );
                }
                if (state.events.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.event_note_outlined,
                    title: 'No Events Found',
                    subtitle: 'Try adjusting your search or category filter.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => notifier.loadEvents(mine: widget.mineOnly),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                      return EventCard(
                        event: event,
                        onTap: () => context.push('/events/${event.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
