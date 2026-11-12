import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel(this._repository);

  final EventRepository _repository;

  List<EventModel> _events = [];
  List<CategoryModel> _categories = [];
  EventModel? _selectedEvent;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  int? _selectedCategoryId;
  String _searchQuery = '';

  List<EventModel> get events => _events;
  List<CategoryModel> get categories => _categories;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (_) {
      // Categories are non-fatal; keep existing list
    }
  }

  Future<void> loadEvents({bool mine = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getEvents(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        mine: mine,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load events.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEvent = await _repository.getEventDetail(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load event details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategoryFilter(int? categoryId, {bool mine = false}) {
    _selectedCategoryId = categoryId;
    loadEvents(mine: mine);
  }

  void setSearchQuery(String query, {bool mine = false}) {
    _searchQuery = query;
    loadEvents(mine: mine);
  }

  Future<bool> saveEvent({
    int? eventId,
    required Map<String, dynamic> payload,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (eventId == null) {
        await _repository.createEvent(payload);
      } else {
        await _repository.updateEvent(eventId, payload);
      }
      await loadEvents();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not save event.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cancelEvent(int eventId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.cancelEvent(eventId);
      await loadEvents(mine: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
