import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../services/event_service.dart';

class EventState {
  const EventState({
    this.events = const [],
    this.categories = const [],
    this.selectedEvent,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  final List<EventModel> events;
  final List<CategoryModel> categories;
  final EventModel? selectedEvent;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final int? selectedCategoryId;
  final String searchQuery;

  EventState copyWith({
    List<EventModel>? events,
    List<CategoryModel>? categories,
    EventModel? selectedEvent,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return EventState(
      events: events ?? this.events,
      categories: categories ?? this.categories,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(EventService(ref.watch(apiClientProvider)));
});

final eventViewModelProvider =
    NotifierProvider<EventViewModel, EventState>(EventViewModel.new);

class EventViewModel extends Notifier<EventState> {
  @override
  EventState build() => const EventState();

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  Future<void> loadCategories() async {
    try {
      final cats = await _repository.getCategories();
      state = state.copyWith(categories: cats);
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> loadEvents({bool mine = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getEvents(
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
        mine: mine,
      );
      state = state.copyWith(events: items, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load events.',
      );
    }
  }

  Future<void> loadEventDetail(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.getEventDetail(id);
      state = state.copyWith(selectedEvent: detail, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load event details.',
      );
    }
  }

  void setCategoryFilter(int? categoryId, {bool mine = false}) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    loadEvents(mine: mine);
  }

  void setSearchQuery(String query, {bool mine = false}) {
    state = state.copyWith(searchQuery: query);
    loadEvents(mine: mine);
  }

  Future<bool> saveEvent({
    int? eventId,
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      if (eventId == null) {
        await _repository.createEvent(payload);
      } else {
        await _repository.updateEvent(eventId, payload);
      }
      await loadEvents();
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not save event.',
      );
      return false;
    }
  }

  Future<bool> cancelEvent(int eventId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.cancelEvent(eventId);
      await loadEvents(mine: true);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    }
  }
}
