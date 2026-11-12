import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/event_card.dart';
import '../../../core/widgets/state_views.dart';
import '../viewmodels/event_viewmodel.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key, this.mineOnly = false});

  final bool mineOnly;

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final vm = context.read<EventViewModel>();
      vm.loadCategories();
      vm.loadEvents(mine: widget.mineOnly);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventViewModel>();

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
                          vm.setSearchQuery('', mine: widget.mineOnly);
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) =>
                  vm.setSearchQuery(value, mine: widget.mineOnly),
            ),
          ),
          if (vm.categories.isNotEmpty)
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
                      selected: vm.selectedCategoryId == null,
                      onSelected: (_) =>
                          vm.setCategoryFilter(null, mine: widget.mineOnly),
                    ),
                  ),
                  ...vm.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: vm.selectedCategoryId == cat.id,
                        onSelected: (_) => vm.setCategoryFilter(cat.id,
                            mine: widget.mineOnly),
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
                if (vm.isLoading) {
                  return const LoadingStateView(message: 'Loading events...');
                }
                if (vm.errorMessage != null) {
                  return ErrorStateView(
                    message: vm.errorMessage!,
                    onRetry: () => vm.loadEvents(mine: widget.mineOnly),
                  );
                }
                if (vm.events.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.event_note_outlined,
                    title: 'No Events Found',
                    subtitle: 'Try adjusting your search or category filter.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => vm.loadEvents(mine: widget.mineOnly),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = vm.events[index];
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
